/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "ChatCore.hpp"
#include "core/App.hpp"
#include "core/chat/message/content/ChatMessageContentGui.hpp"
#include "core/friend/FriendCore.hpp"
#include "core/setting/SettingsCore.hpp"
#include "model/core/CoreModel.hpp"
#include "model/friend/FriendModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(ChatCore)

/***********************************************************************/

QSharedPointer<ChatCore> ChatCore::create(const std::shared_ptr<linphone::ChatRoom> &chatRoom) {
	auto sharedPointer = QSharedPointer<ChatCore>(new ChatCore(chatRoom), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

ChatCore::ChatCore(const std::shared_ptr<linphone::ChatRoom> &chatRoom) : QObject(nullptr) {
	// lDebug() << "[ChatCore] new" << this;
	mustBeInLinphoneThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mLastUpdatedTime = QDateTime::fromSecsSinceEpoch(chatRoom->getLastUpdateTime());
	auto chatRoomAddress = chatRoom->getPeerAddress()->clone();
	chatRoomAddress->clean();
	mChatRoomAddress = Utils::coreStringToAppString(chatRoomAddress->asStringUriOnly());
	if (chatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::Basic)) {
		mTitle = ToolModel::getDisplayName(chatRoomAddress);
		mAvatarUri = ToolModel::getDisplayName(chatRoomAddress);
		mPeerAddress = Utils::coreStringToAppString(chatRoomAddress->asStringUriOnly());
		mIsGroupChat = false;
	} else {
		if (chatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::OneToOne)) {
			auto participants = chatRoom->getParticipants();
			if (participants.size() > 0) {
				auto peer = participants.front();
				if (peer) mTitle = ToolModel::getDisplayName(peer->getAddress()->clone());
				mAvatarUri = ToolModel::getDisplayName(peer->getAddress()->clone());
				if (participants.size() == 1) {
					auto peerAddress = peer->getAddress();
					if (peerAddress) mPeerAddress = Utils::coreStringToAppString(peerAddress->asStringUriOnly());
				}
			}
			mIsGroupChat = false;
		} else if (chatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::Conference)) {
			mTitle = Utils::coreStringToAppString(chatRoom->getSubject());
			mAvatarUri = Utils::coreStringToAppString(chatRoom->getSubject());
			mIsGroupChat = true;
			mMeAdmin = chatRoom->getMe() && chatRoom->getMe()->isAdmin();
		}
	}
	mUnreadMessagesCount = chatRoom->getUnreadMessagesCount();
	connect(this, &ChatCore::unreadMessagesCountChanged, this, [this] {
		if (mUnreadMessagesCount == 0) emit lMarkAsRead();
	});
	mChatModel = Utils::makeQObject_ptr<ChatModel>(chatRoom);
	mChatModel->setSelf(mChatModel);
	auto lastMessage = chatRoom->getLastMessageInHistory();
	mLastMessage = lastMessage ? ChatMessageCore::create(lastMessage) : nullptr;

	int filter = mIsGroupChat ? static_cast<int>(linphone::ChatRoom::HistoryFilter::ChatMessage) |
	                                static_cast<int>(linphone::ChatRoom::HistoryFilter::InfoNoDevice)
	                          : static_cast<int>(linphone::ChatRoom::HistoryFilter::ChatMessage);

	auto history = chatRoom->getHistory(0, filter);
	std::list<std::shared_ptr<linphone::EventLog>> lHistory;
	for (auto &eventLog : history) {
		lHistory.push_back(eventLog);
	}
	QList<QSharedPointer<EventLogCore>> eventList;
	for (auto &event : lHistory) {
		auto eventLogCore = EventLogCore::create(event);
		eventList.append(eventLogCore);
		if (auto isMessage = eventLogCore->getChatMessageCore()) {
			for (auto content : isMessage->getChatMessageContentList()) {
				if (content->isFile() && !content->isVoiceRecording()) {
					mFileList.append(content);
				}
			}
		}
	}
	resetEventLogList(eventList);
	mIdentifier = Utils::coreStringToAppString(chatRoom->getIdentifier());
	mChatRoomState = LinphoneEnums::fromLinphone(chatRoom->getState());
	mIsEncrypted = chatRoom->hasCapability((int)linphone::ChatRoom::Capabilities::Encrypted);
	auto localAccount = ToolModel::findAccount(chatRoom->getLocalAddress());
	bool associatedAccountHasIMEncryptionMandatory =
	    localAccount && localAccount->getParams() &&
	    localAccount->getParams()->getInstantMessagingEncryptionMandatory();
	mIsReadOnly = chatRoom->isReadOnly() || (!mIsEncrypted && associatedAccountHasIMEncryptionMandatory);
	connect(this, &ChatCore::eventListChanged, this, &ChatCore::lUpdateLastMessage);
	connect(this, &ChatCore::eventsInserted, this, &ChatCore::lUpdateLastMessage);
	connect(this, &ChatCore::eventRemoved, this, &ChatCore::lUpdateLastMessage);
	auto resetFileListLambda = [this] {
		QList<QSharedPointer<ChatMessageContentCore>> fileList;
		for (auto &eventLogCore : mEventLogList) {
			if (auto isMessage = eventLogCore->getChatMessageCore()) {
				for (auto content : isMessage->getChatMessageContentList()) {
					if (content->isFile() && !content->isVoiceRecording()) {
						fileList.append(content);
					}
				}
			}
		}
		resetFileList(fileList);
	};
	connect(this, &ChatCore::eventListChanged, this, resetFileListLambda);
	connect(this, &ChatCore::eventsInserted, this, resetFileListLambda);
	connect(this, &ChatCore::eventRemoved, this, resetFileListLambda);
	mEphemeralEnabled = chatRoom->ephemeralEnabled();
	mEphemeralLifetime = chatRoom->ephemeralEnabled() ? chatRoom->getEphemeralLifetime() : 0;
	mIsMuted = chatRoom->getMuted();
	mParticipants = buildParticipants(chatRoom);
}

ChatCore::~ChatCore() {
	lDebug() << "[ChatCore] delete" << this;
	mustBeInMainThread("~" + getClassName());
	mChatModelConnection->disconnect();
	emit mChatModel->removeListener();
}

void ChatCore::setSelf(QSharedPointer<ChatCore> me) {
	mChatModelConnection = SafeConnection<ChatCore, ChatModel>::create(me, mChatModel);
	mChatModelConnection->makeConnectToCore(&ChatCore::lDeleteHistory, [this]() {
		mChatModelConnection->invokeToModel([this]() { mChatModel->deleteHistory(); });
	});
	mChatModelConnection->makeConnectToCore(&ChatCore::lDeleteMessage, [this](ChatMessageGui *message) {
		mChatModelConnection->invokeToModel([this, core = message ? message->mCore : nullptr]() {
			auto messageModel = core ? core->getModel() : nullptr;
			if (messageModel) {
				mChatModel->deleteMessage(messageModel->getMonitor());
			}
		});
	});

	mChatModelConnection->makeConnectToCore(
	    &ChatCore::lLeave, [this]() { mChatModelConnection->invokeToModel([this]() { mChatModel->leave(); }); });
	mChatModelConnection->makeConnectToModel(&ChatModel::historyDeleted, [this]() {
		mChatModelConnection->invokeToCore([this]() {
			clearEventLogList();
			//: Deleted
			Utils::showInformationPopup(tr("info_toast_deleted_title"),
			                            //: Message history has been deleted
			                            tr("info_toast_deleted_message_history"), true);
		});
	});
	mChatModelConnection->makeConnectToCore(&ChatCore::lUpdateUnreadCount, [this]() {
		mChatModelConnection->invokeToModel([this]() {
			auto count = mChatModel->getUnreadMessagesCount();
			mChatModelConnection->invokeToCore([this, count] { setUnreadMessagesCount(count); });
		});
	});
	mChatModelConnection->makeConnectToCore(&ChatCore::lUpdateLastUpdatedTime, [this]() {
		mChatModelConnection->invokeToModel([this]() {
			auto time = mChatModel->getLastUpdateTime();
			mChatModelConnection->invokeToCore([this, time]() { setLastUpdatedTime(time); });
		});
	});

	mChatModelConnection->makeConnectToCore(&ChatCore::lDelete, [this]() {
		mChatModelConnection->invokeToModel([this]() { mChatModel->deleteChatRoom(); });
	});
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::deleted, [this]() { mChatModelConnection->invokeToCore([this]() { emit deleted(); }); });
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::stateChanged,
	    [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom, linphone::ChatRoom::State newState) {
		    auto state = LinphoneEnums::fromLinphone(newState);
		    bool isReadOnly = chatRoom->isReadOnly();
		    mChatModelConnection->invokeToCore([this, state, isReadOnly]() {
			    setChatRoomState(state);
			    setIsReadOnly(isReadOnly);
		    });
	    });

	// Events (excluding messages)
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::newEvent, [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                 const std::shared_ptr<const linphone::EventLog> &eventLog) {
		    if (mChatModel->getMonitor() != chatRoom) return;
		    qDebug() << "EVENT LOG RECEIVED IN CHATROOM" << mChatModel->getTitle();
		    auto event = EventLogCore::create(eventLog);
		    if (event->isHandled()) {
			    mChatModelConnection->invokeToCore([this, event]() { appendEventLogToEventLogList(event); });
		    }
		    mChatModelConnection->invokeToCore([this, event]() { emit lUpdateLastUpdatedTime(); });
	    });

	// Chat messages
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::chatMessagesReceived, [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                             const std::list<std::shared_ptr<linphone::EventLog>> &eventsLog) {
		    if (mChatModel->getMonitor() != chatRoom) return;
		    qDebug() << "CHAT MESSAGE RECEIVED IN CHATROOM" << mChatModel->getTitle();
		    QList<QSharedPointer<EventLogCore>> list;
		    for (auto &e : eventsLog) {
			    auto event = EventLogCore::create(e);
			    list.push_back(event);
		    }
		    mChatModelConnection->invokeToCore([this, list]() {
			    appendEventLogsToEventLogList(list);
			    emit lUpdateUnreadCount();
			    emit lUpdateLastUpdatedTime();
		    });
	    });

	mChatModelConnection->makeConnectToCore(&ChatCore::lMarkAsRead, [this]() {
		mChatModelConnection->invokeToModel([this]() { mChatModel->markAsRead(); });
	});
	mChatModelConnection->makeConnectToModel(&ChatModel::messagesRead, [this]() {
		auto unread = mChatModel->getUnreadMessagesCount();
		mChatModelConnection->invokeToCore([this, unread]() { setUnreadMessagesCount(unread); });
	});

	mChatModelConnection->makeConnectToCore(&ChatCore::lUpdateLastMessage, [this]() {
		auto lastMessageModel = mLastMessage ? mLastMessage->getModel() : nullptr;
		mChatModelConnection->invokeToModel([this, lastMessageModel]() {
			auto linphoneMessage = mChatModel->getLastChatMessage();
			if (linphoneMessage && (!lastMessageModel || lastMessageModel->getMonitor() != linphoneMessage)) {
				auto chatMessageCore = ChatMessageCore::create(linphoneMessage);
				mChatModelConnection->invokeToCore([this, chatMessageCore]() { setLastMessage(chatMessageCore); });
			}
		});
	});
	mChatModelConnection->makeConnectToCore(&ChatCore::lSendTextMessage, [this](QString message) {
		if (Utils::isEmptyMessage(message)) return;
		mChatModelConnection->invokeToModel([this, message]() {
			auto linMessage = mChatModel->createTextMessageFromText(message);
			linMessage->send();
		});
	});
	mChatModelConnection->makeConnectToCore(&ChatCore::lSendMessage, [this](QString message, QVariantList files) {
		if (Utils::isEmptyMessage(message) && files.size() == 0) return;
		QList<std::shared_ptr<ChatMessageContentModel>> filesContent;
		for (auto &file : files) {
			auto contentGui = qvariant_cast<ChatMessageContentGui *>(file);
			if (contentGui) {
				auto contentCore = contentGui->mCore;
				filesContent.append(contentCore->getContentModel());
			}
		}
		mChatModelConnection->invokeToModel([this, message, filesContent]() {
			auto linMessage = mChatModel->createMessage(message, filesContent);
			linMessage->send();
		});
	});
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::chatMessageSending, [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                           const std::shared_ptr<const linphone::EventLog> &eventLog) {
		    auto event = EventLogCore::create(eventLog);
		    mChatModelConnection->invokeToCore([this, event]() { appendEventLogToEventLogList(event); });
	    });
	mChatModelConnection->makeConnectToCore(
	    &ChatCore::lCompose, [this]() { mChatModelConnection->invokeToModel([this]() { mChatModel->compose(); }); });
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::isComposingReceived,
	    [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	           const std::shared_ptr<const linphone::Address> &remoteAddress, bool isComposing) {
		    if (mChatModel->getMonitor() != chatRoom) return;
		    QString name = isComposing ? ToolModel::getDisplayName(remoteAddress->clone()) : QString();
		    auto remoteAddr = remoteAddress->clone();
		    remoteAddr->clean();
		    mChatModelConnection->invokeToCore(
		        [this, name, address = Utils::coreStringToAppString(remoteAddr->asStringUriOnly())]() {
			        setComposingName(name);
			        setComposingAddress(address);
		        });
	    });
	mChatModelConnection->makeConnectToCore(&ChatCore::lSetMuted, [this](bool muted) {
		mChatModelConnection->invokeToModel([this, muted]() { mChatModel->setMuted(muted); });
	});
	mChatModelConnection->makeConnectToModel(&ChatModel::mutedChanged, [this](bool muted) {
		mChatModelConnection->invokeToCore([this, muted]() {
			if (mIsMuted != muted) {
				mIsMuted = muted;
				emit mutedChanged();
			}
		});
	});

	mChatModelConnection->makeConnectToCore(&ChatCore::lEnableEphemeral, [this](bool enable) {
		mChatModelConnection->invokeToModel([this, enable]() { mChatModel->enableEphemeral(enable); });
	});
	mChatModelConnection->makeConnectToModel(&ChatModel::ephemeralEnableChanged, [this](bool enable) {
		mChatModelConnection->invokeToCore([this, enable]() {
			if (mEphemeralEnabled != enable) {
				mEphemeralEnabled = enable;
				emit ephemeralEnabledChanged();
			}
		});
	});

	mChatModelConnection->makeConnectToCore(&ChatCore::lSetEphemeralLifetime, [this](int time) {
		mChatModelConnection->invokeToModel([this, time]() { mChatModel->setEphemeralLifetime(time); });
	});
	mChatModelConnection->makeConnectToModel(&ChatModel::ephemeralLifetimeChanged, [this](int time) {
		mChatModelConnection->invokeToCore([this, time]() {
			if (mEphemeralLifetime != time) {
				mEphemeralLifetime = time;
				emit ephemeralLifetimeChanged();
			}
		});
	});

	mChatModelConnection->makeConnectToCore(&ChatCore::lSetSubject, [this](QString subject) {
		mChatModelConnection->invokeToModel([this, subject]() { mChatModel->setSubject(subject); });
	});
	mChatModelConnection->makeConnectToModel(
	    &ChatModel::subjectChanged, [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                       const std::shared_ptr<const linphone::EventLog> &eventLog) {
		    QString subject = Utils::coreStringToAppString(chatRoom->getSubject());
		    mChatModelConnection->invokeToCore([this, subject]() { setTitle(subject); });
	    });

	mChatModelConnection->makeConnectToModel(&ChatModel::participantAdded,
	                                         [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                                const std::shared_ptr<const linphone::EventLog> &eventLog) {
		                                         auto participants = buildParticipants(chatRoom);
		                                         mChatModelConnection->invokeToCore([this, participants]() {
			                                         mParticipants = participants;
			                                         emit participantsChanged();
		                                         });
	                                         });
	mChatModelConnection->makeConnectToModel(&ChatModel::participantRemoved,
	                                         [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                                const std::shared_ptr<const linphone::EventLog> &eventLog) {
		                                         auto participants = buildParticipants(chatRoom);
		                                         mChatModelConnection->invokeToCore([this, participants]() {
			                                         mParticipants = participants;
			                                         emit participantsChanged();
		                                         });
	                                         });
	mChatModelConnection->makeConnectToModel(&ChatModel::participantAdminStatusChanged,
	                                         [this](const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                                const std::shared_ptr<const linphone::EventLog> &eventLog) {
		                                         auto participants = buildParticipants(chatRoom);
		                                         mChatModelConnection->invokeToCore([this, participants]() {
			                                         mParticipants = participants;
			                                         emit participantsChanged();
		                                         });
	                                         });
	mChatModelConnection->makeConnectToCore(&ChatCore::lRemoveParticipantAtIndex, [this](int index) {
		mChatModelConnection->invokeToModel([this, index]() { mChatModel->removeParticipantAtIndex(index); });
	});

	mChatModelConnection->makeConnectToCore(&ChatCore::lSetParticipantsAddresses, [this](QStringList addresses) {
		mChatModelConnection->invokeToModel([this, addresses]() { mChatModel->setParticipantAddresses(addresses); });
	});

	mChatModelConnection->makeConnectToCore(&ChatCore::lToggleParticipantAdminStatusAtIndex, [this](int index) {
		mChatModelConnection->invokeToModel(
		    [this, index]() { mChatModel->toggleParticipantAdminStatusAtIndex(index); });
	});

	mCoreModelConnection = SafeConnection<ChatCore, CoreModel>::create(me, CoreModel::getInstance());
	if (!ToolModel::findFriendByAddress(mPeerAddress))
		mCoreModelConnection->makeConnectToModel(&CoreModel::friendCreated,
		                                         [this](std::shared_ptr<linphone::Friend> f) { updateInfo(f); });
	mCoreModelConnection->makeConnectToModel(&CoreModel::friendUpdated,
	                                         [this](std::shared_ptr<linphone::Friend> f) { updateInfo(f); });
	mCoreModelConnection->makeConnectToModel(&CoreModel::friendRemoved,
	                                         [this](std::shared_ptr<linphone::Friend> f) { updateInfo(f, true); });
}

QDateTime ChatCore::getLastUpdatedTime() const {
	return mLastUpdatedTime;
}

void ChatCore::setLastUpdatedTime(QDateTime time) {
	if (mLastUpdatedTime != time) {
		mLastUpdatedTime = time;
		emit lastUpdatedTimeChanged(time);
	}
}

QString ChatCore::getTitle() const {
	return mTitle;
}

void ChatCore::setTitle(QString title) {
	if (mTitle != title) {
		mTitle = title;
		emit titleChanged(title);
	}
}

QString ChatCore::getSendingText() const {
	return mSendingText;
}

void ChatCore::setSendingText(const QString &text) {
	if (mSendingText != text) {
		mSendingText = text;
		emit sendingTextChanged(text);
	}
}

bool ChatCore::isGroupChat() const {
	return mIsGroupChat;
}

bool ChatCore::isEncrypted() const {
	return mIsEncrypted;
}

QString ChatCore::getIdentifier() const {
	return mIdentifier;
}

QString ChatCore::getPeerAddress() const {
	return mPeerAddress;
}

QString ChatCore::getChatRoomAddress() const {
	return mChatRoomAddress;
}

QString ChatCore::getAvatarUri() const {
	return mAvatarUri;
}

void ChatCore::setAvatarUri(QString avatarUri) {
	if (mAvatarUri != avatarUri) {
		mAvatarUri = avatarUri;
		emit avatarUriChanged();
	}
}

QString ChatCore::getLastMessageText() const {
	return mLastMessage ? mLastMessage->getText() : QString();
}

LinphoneEnums::ChatMessageState ChatCore::getLastMessageState() const {
	return mLastMessage ? mLastMessage->getMessageState() : LinphoneEnums::ChatMessageState::StateIdle;
}

LinphoneEnums::ChatRoomState ChatCore::getChatRoomState() const {
	return mChatRoomState;
}

void ChatCore::setChatRoomState(LinphoneEnums::ChatRoomState state) {
	if (mChatRoomState != state) {
		mChatRoomState = state;
		emit chatRoomStateChanged();
	}
}

void ChatCore::setIsReadOnly(bool readOnly) {
	if (mIsReadOnly != readOnly) {
		mIsReadOnly = readOnly;
		emit readOnlyChanged();
	}
}

bool ChatCore::getIsReadOnly() const {
	return mIsReadOnly;
}

ChatMessageGui *ChatCore::getLastMessage() const {
	return mLastMessage ? new ChatMessageGui(mLastMessage) : nullptr;
}

void ChatCore::setLastMessage(QSharedPointer<ChatMessageCore> lastMessage) {
	if (mLastMessage != lastMessage) {
		disconnect(mLastMessage.get());
		mLastMessage = lastMessage;
		connect(mLastMessage.get(), &ChatMessageCore::messageStateChanged, this, &ChatCore::lastMessageChanged);
		emit lastMessageChanged();
	}
}

int ChatCore::getUnreadMessagesCount() const {
	return mUnreadMessagesCount;
}

void ChatCore::setUnreadMessagesCount(int count) {
	if (mUnreadMessagesCount != count) {
		mUnreadMessagesCount = count;
		emit unreadMessagesCountChanged(count);
	}
}

QList<QSharedPointer<EventLogCore>> ChatCore::getEventLogList() const {
	return mEventLogList;
}

void ChatCore::resetEventLogList(QList<QSharedPointer<EventLogCore>> list) {
	for (auto &e : mEventLogList) {
		disconnect(e.get());
	}
	for (auto &e : list) {
		if (auto message = e->getChatMessageCore()) {
			connect(message.get(), &ChatMessageCore::isReadChanged, this, [this] { emit lUpdateUnreadCount(); });
		}
	}
	mEventLogList = list;
	emit eventListChanged();
}

void ChatCore::appendEventLogsToEventLogList(QList<QSharedPointer<EventLogCore>> list) {
	int nbAdded = 0;
	for (auto &e : list) {
		if (mEventLogList.contains(e)) continue;
		if (auto message = e->getChatMessageCore())
			connect(message.get(), &ChatMessageCore::isReadChanged, this, [this] { emit lUpdateUnreadCount(); });
		mEventLogList.append(e);
		++nbAdded;
	}
	if (nbAdded > 0) emit eventsInserted(list);
}

void ChatCore::appendEventLogToEventLogList(QSharedPointer<EventLogCore> e) {
	if (mEventLogList.contains(e)) return;
	auto it = std::find_if(mEventLogList.begin(), mEventLogList.end(), [e](QSharedPointer<EventLogCore> event) {
		return e->getEventLogId() == event->getEventLogId();
	});
	if (it == mEventLogList.end()) {
		if (auto message = e->getChatMessageCore())
			connect(message.get(), &ChatMessageCore::isReadChanged, this, [this] { emit lUpdateUnreadCount(); });
		mEventLogList.append(e);
		emit eventsInserted({e});
	}
}

void ChatCore::removeEventLogsFromEventLogList(QList<QSharedPointer<EventLogCore>> list) {
	int nbRemoved = 0;
	for (auto &e : list) {
		if (mEventLogList.contains(e)) {
			if (auto message = e->getChatMessageCore()) disconnect(message.get());
			mEventLogList.removeAll(e);
			++nbRemoved;
		}
	}
	if (nbRemoved > 0) emit eventRemoved();
}

void ChatCore::clearEventLogList() {
	for (auto &e : mEventLogList) {
		disconnect(e.get());
	}
	mEventLogList.clear();
	emit eventListChanged();
}

QString ChatCore::getComposingName() const {
	return mComposingName;
}

void ChatCore::setComposingName(QString composingName) {
	if (mComposingAddress != composingName) {
		mComposingName = composingName;
		emit composingUserChanged();
	}
}

void ChatCore::setComposingAddress(QString composingAddress) {
	if (mComposingAddress != composingAddress) {
		mComposingAddress = composingAddress;
		emit composingUserChanged();
	}
}

QString ChatCore::getComposingAddress() const {
	return mComposingAddress;
}

QList<QSharedPointer<ChatMessageContentCore>> ChatCore::getFileList() const {
	return mFileList;
}

void ChatCore::resetFileList(QList<QSharedPointer<ChatMessageContentCore>> list) {
	mFileList = list;
	emit fileListChanged();
}

std::shared_ptr<ChatModel> ChatCore::getModel() const {
	return mChatModel;
}

bool ChatCore::isMuted() const {
	return mIsMuted;
}

bool ChatCore::isEphemeralEnabled() const {
	return mEphemeralEnabled;
}

int ChatCore::getEphemeralLifetime() const {
	return mEphemeralLifetime;
}

void ChatCore::setMeAdmin(bool admin) {
	if (mMeAdmin != admin) {
		mMeAdmin = admin;
		emit meAdminChanged();
	}
}

bool ChatCore::getMeAdmin() const {
	return mMeAdmin;
}

QVariantList ChatCore::getParticipantsGui() const {
	QVariantList result;
	for (auto participantCore : mParticipants) {
		auto participantGui = new ParticipantGui(participantCore);
		result.append(QVariant::fromValue(participantGui));
	}
	return result;
}

QStringList ChatCore::getParticipantsAddresses() const {
	QStringList result;
	for (auto participantCore : mParticipants) {
		result.append(participantCore->getSipAddress());
	}
	return result;
}

QList<QSharedPointer<ParticipantCore>>
ChatCore::buildParticipants(const std::shared_ptr<linphone::ChatRoom> &chatRoom) const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	QList<QSharedPointer<ParticipantCore>> result;
	for (auto participant : chatRoom->getParticipants()) {
		auto participantCore = ParticipantCore::create(participant);
		result.append(participantCore);
	}
	return result;
}

QList<QSharedPointer<ParticipantCore>> ChatCore::getParticipants() const {
	return mParticipants;
}

void ChatCore::updateInfo(const std::shared_ptr<linphone::Friend> &updatedFriend, bool isRemoval) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto fAddress = ToolModel::interpretUrl(mPeerAddress);
	bool isThisFriend = mFriendModel && updatedFriend == mFriendModel->getFriend();
	if (!isThisFriend)
		for (auto f : updatedFriend->getAddresses()) {
			if (f->weakEqual(fAddress)) {
				isThisFriend = true;
				break;
			}
		}
	if (isThisFriend) {
		if (isRemoval) {
			mFriendModel = nullptr;
			mFriendModelConnection = nullptr;
		}
		int capabilities = mChatModel->getCapabilities();
		auto chatroom = mChatModel->getMonitor();
		auto chatRoomAddress = chatroom->getPeerAddress()->clone();
		if (mChatModel->hasCapability((int)linphone::ChatRoom::Capabilities::Basic)) {
			mTitle = ToolModel::getDisplayName(chatRoomAddress);
			mAvatarUri = ToolModel::getDisplayName(chatRoomAddress);
			emit titleChanged(mTitle);
			emit avatarUriChanged();
		} else {
			if (mChatModel->hasCapability((int)linphone::ChatRoom::Capabilities::OneToOne)) {
				auto participants = chatroom->getParticipants();
				if (participants.size() > 0) {
					auto peer = participants.front();
					if (peer) mTitle = ToolModel::getDisplayName(peer->getAddress()->clone());
					mAvatarUri = ToolModel::getDisplayName(peer->getAddress()->clone());
					if (participants.size() == 1) {
						auto peerAddress = peer->getAddress();
						if (peerAddress) mPeerAddress = Utils::coreStringToAppString(peerAddress->asStringUriOnly());
					}
				}
			} else if (mChatModel->hasCapability((int)linphone::ChatRoom::Capabilities::Conference)) {
				mTitle = Utils::coreStringToAppString(chatroom->getSubject());
				mAvatarUri = Utils::coreStringToAppString(chatroom->getSubject());
			}
		}
	}
}