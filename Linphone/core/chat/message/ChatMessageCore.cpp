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

#include "ChatMessageCore.hpp"
#include "core/App.hpp"
#include "model/tool/ToolModel.hpp"

#include <QQuickWindow>

DEFINE_ABSTRACT_OBJECT(ChatMessageCore)

/***********************************************************************/

ImdnStatus ImdnStatus::operator=(ImdnStatus r) {
	mAddress = r.mAddress;
	mState = r.mState;
	mLastUpdatedTime = r.mLastUpdatedTime;
	return *this;
}

bool ImdnStatus::operator==(const ImdnStatus &r) const {
	return r.mState == mState && r.mAddress == mAddress && r.mLastUpdatedTime == mLastUpdatedTime;
}

bool ImdnStatus::operator!=(ImdnStatus r) {
	return r.mState != mState || r.mAddress != mAddress || r.mLastUpdatedTime != mLastUpdatedTime;
}

ImdnStatus::ImdnStatus() {
}

ImdnStatus::ImdnStatus(const QString &address,
                       const LinphoneEnums::ChatMessageState &state,
                       QDateTime lastUpdatedTime) {
	mState = state;
	mAddress = address;
	mLastUpdatedTime = lastUpdatedTime;
}

ImdnStatus ImdnStatus::createMessageImdnStatusVariant(const QString &address,
                                                      const LinphoneEnums::ChatMessageState &state,
                                                      QDateTime lastUpdatedTime) {
	ImdnStatus s;
	s.mState = state;
	s.mAddress = address;
	s.mLastUpdatedTime = lastUpdatedTime;
	return s;
}

QVariant createImdnStatusSingletonVariant(const LinphoneEnums::ChatMessageState &state, int count = 1) {
	QVariantMap map;
	map.insert("state", QVariant::fromValue(state));
	map.insert("count", count);
	return map;
}

/***********************************************************************/

Reaction Reaction::operator=(Reaction r) {
	mAddress = r.mAddress;
	mBody = r.mBody;
	return *this;
}
bool Reaction::operator==(const Reaction &r) const {
	return r.mBody == mBody && r.mAddress == mAddress;
}
bool Reaction::operator!=(Reaction r) {
	return r.mBody != mBody || r.mAddress != mAddress;
}

Reaction Reaction::createMessageReactionVariant(const QString &body, const QString &address) {
	Reaction r;
	r.mBody = body;
	r.mAddress = address;
	return r;
}

QVariant createReactionSingletonVariant(const QString &body, int count = 1) {
	QVariantMap map;
	map.insert("body", body);
	map.insert("count", count);
	return map;
}

/***********************************************************************/

QSharedPointer<ChatMessageCore> ChatMessageCore::create(const std::shared_ptr<linphone::ChatMessage> &chatmessage) {
	auto sharedPointer = QSharedPointer<ChatMessageCore>(new ChatMessageCore(chatmessage), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

ChatMessageCore::ChatMessageCore(const std::shared_ptr<linphone::ChatMessage> &chatmessage) {
	// lDebug() << "[ChatMessageCore] new" << this;
	mustBeInLinphoneThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	if (chatmessage) {
		mChatMessageModel = Utils::makeQObject_ptr<ChatMessageModel>(chatmessage);
		mChatMessageModel->setSelf(mChatMessageModel);
		mText = ToolModel::getMessageFromContent(chatmessage->getContents());
		mUtf8Text = mChatMessageModel->getUtf8Text();
		mHasTextContent = mChatMessageModel->getHasTextContent();
		mTimestamp = QDateTime::fromSecsSinceEpoch(chatmessage->getTime());
		mIsOutgoing = chatmessage->isOutgoing();
		mIsRemoteMessage = !chatmessage->isOutgoing();
		mPeerAddress = Utils::coreStringToAppString(chatmessage->getPeerAddress()->asStringUriOnly());
		mPeerName = ToolModel::getDisplayName(chatmessage->getPeerAddress());
		auto fromAddress = chatmessage->getFromAddress();
		// fromAddress->clean();
		mFromAddress = Utils::coreStringToAppString(fromAddress->asStringUriOnly());
		mFromName = ToolModel::getDisplayName(chatmessage->getFromAddress());
		mToName = ToolModel::getDisplayName(chatmessage->getToAddress());
		auto chatroom = chatmessage->getChatRoom();
		mIsFromChatGroup = chatroom->hasCapability((int)linphone::ChatRoom::Capabilities::Conference) &&
		                   !chatroom->hasCapability((int)linphone::ChatRoom::Capabilities::OneToOne);
		mIsRead = chatmessage->isRead();
		mMessageState = LinphoneEnums::fromLinphone(chatmessage->getState());
		mIsEphemeral = chatmessage->isEphemeral();

		if (mIsEphemeral) {
			auto now = QDateTime::currentDateTime();
			mEphemeralDuration = chatmessage->getEphemeralExpireTime() == 0
			                         ? chatmessage->getEphemeralLifetime()
			                         : now.secsTo(QDateTime::fromSecsSinceEpoch(chatmessage->getEphemeralExpireTime()));
		}
		mMessageId = Utils::coreStringToAppString(chatmessage->getMessageId());
		for (auto content : chatmessage->getContents()) {
			auto contentCore = ChatMessageContentCore::create(content, mChatMessageModel);
			mChatMessageContentList.push_back(contentCore);
			if ((content->isFile() || content->isFileTransfer()) && !content->isVoiceRecording())
				mHasFileContent = true;
			if (content->isIcalendar()) mIsCalendarInvite = true;
			if (content->isVoiceRecording()) {
				mIsVoiceRecording = true;
				mVoiceRecordingContent = contentCore;
			}
		}
		//: "Reactions": all reactions for one message label
		mTotalReactionsLabel = tr("all_reactions_label");
		auto reac = chatmessage->getOwnReaction();
		mOwnReaction = reac ? Utils::coreStringToAppString(reac->getBody()) : QString();
		for (auto &reaction : chatmessage->getReactions()) {
			if (reaction) {
				auto fromAddr = reaction->getFromAddress()->clone();
				fromAddr->clean();
				auto reac =
				    Reaction::createMessageReactionVariant(Utils::coreStringToAppString(reaction->getBody()),
				                                           Utils::coreStringToAppString(fromAddr->asStringUriOnly()));
				mReactions.append(reac);

				auto it = std::find_if(mReactionsSingletonMap.begin(), mReactionsSingletonMap.end(),
				                       [body = reac.mBody](QVariant data) {
					                       auto dataBody = data.toMap()["body"].toString();
					                       return body == dataBody;
				                       });
				if (it == mReactionsSingletonMap.end())
					mReactionsSingletonMap.push_back(createReactionSingletonVariant(reac.mBody, 1));
				else {
					auto map = it->toMap();
					auto count = map["count"].toInt();
					++count;
					map.remove("count");
					map.insert("count", count);
					mReactionsSingletonMap.erase(it);
					mReactionsSingletonMap.push_back(map);
				}
			}
		}
		connect(this, &ChatMessageCore::messageReactionChanged, this, &ChatMessageCore::resetReactionsSingleton);

		mIsForward = chatmessage->isForward();
		mIsReply = chatmessage->isReply();
		if (mIsReply) {
			auto replymessage = chatmessage->getReplyMessage();
			if (replymessage) {
				mReplyText = ToolModel::getMessageFromContent(replymessage->getContents());
				if (mIsFromChatGroup) mRepliedToName = ToolModel::getDisplayName(replymessage->getFromAddress());
			}
		}
		mImdnStatusList = computeDeliveryStatus(chatmessage);
	}
}

ChatMessageCore::~ChatMessageCore() {
}

void ChatMessageCore::setSelf(QSharedPointer<ChatMessageCore> me) {
	mChatMessageModelConnection = SafeConnection<ChatMessageCore, ChatMessageModel>::create(me, mChatMessageModel);
	mChatMessageModelConnection->makeConnectToCore(&ChatMessageCore::lDelete, [this] {
		mChatMessageModelConnection->invokeToModel([this] { mChatMessageModel->deleteMessageFromChatRoom(true); });
	});
	mChatMessageModelConnection->makeConnectToModel(&ChatMessageModel::messageDeleted, [this](bool deletedByUser) {
		mChatMessageModelConnection->invokeToCore([this, deletedByUser] {
			//: Deleted
			if (deletedByUser)
				Utils::showInformationPopup(tr("info_toast_deleted_title"),
				                            //: The message has been deleted
				                            tr("info_toast_deleted_message"), true);
			emit deleted();
		});
	});
	mChatMessageModelConnection->makeConnectToCore(&ChatMessageCore::lMarkAsRead, [this] {
		auto mainWindow = Utils::getMainWindow();
		if (mainWindow->isActive())
			mChatMessageModelConnection->invokeToModel([this] { mChatMessageModel->markAsRead(); });
		else {
			connect(mainWindow, &QQuickWindow::activeChanged, this, [this, mainWindow] {
				if (mainWindow->isActive()) {
					disconnect(mainWindow, &QQuickWindow::activeChanged, this, nullptr);
					mChatMessageModelConnection->invokeToModel([this, mainWindow] { mChatMessageModel->markAsRead(); });
				}
			});
		}
	});
	mChatMessageModelConnection->makeConnectToModel(&ChatMessageModel::messageRead, [this]() {
		mChatMessageModelConnection->invokeToCore([this] { setIsRead(true); });
	});
	mChatMessageModelConnection->makeConnectToCore(&ChatMessageCore::lSendReaction, [this](const QString &reaction) {
		mChatMessageModelConnection->invokeToModel([this, reaction] { mChatMessageModel->sendReaction(reaction); });
	});
	mChatMessageModelConnection->makeConnectToCore(&ChatMessageCore::lRemoveReaction, [this]() {
		mChatMessageModelConnection->invokeToModel([this] { mChatMessageModel->removeReaction(); });
	});
	mChatMessageModelConnection->makeConnectToCore(&ChatMessageCore::lSend, [this]() {
		mChatMessageModelConnection->invokeToModel([this] { mChatMessageModel->send(); });
	});
	mChatMessageModelConnection->makeConnectToModel(
	    &ChatMessageModel::newMessageReaction,
	    [this](const std::shared_ptr<linphone::ChatMessage> &message,
	           const std::shared_ptr<const linphone::ChatMessageReaction> &reaction) {
		    auto ownReac = message->getOwnReaction();
		    auto own = ownReac ? Utils::coreStringToAppString(message->getOwnReaction()->getBody()) : QString();
		    // We must reset all the reactions each time cause reactionRemoved is not emitted
		    // when someone change its current reaction
		    QList<Reaction> reactions;
		    for (auto &reaction : message->getReactions()) {
			    if (reaction) {
				    auto fromAddr = reaction->getFromAddress()->clone();
				    fromAddr->clean();
				    reactions.append(Reaction::createMessageReactionVariant(
				        Utils::coreStringToAppString(reaction->getBody()),
				        Utils::coreStringToAppString(fromAddr->asStringUriOnly())));
			    }
		    }
		    mChatMessageModelConnection->invokeToCore([this, own, reactions] {
			    setOwnReaction(own);
			    setReactions(reactions);
		    });
	    });
	mChatMessageModelConnection->makeConnectToModel(
	    &ChatMessageModel::reactionRemoved, [this](const std::shared_ptr<linphone::ChatMessage> &message,
	                                               const std::shared_ptr<const linphone::Address> &address) {
		    auto reac = message->getOwnReaction();
		    auto own = reac ? Utils::coreStringToAppString(message->getOwnReaction()->getBody()) : QString();
		    auto addr = address->clone();
		    addr->clean();
		    QString addressString = Utils::coreStringToAppString(addr->asStringUriOnly());
		    mChatMessageModelConnection->invokeToCore([this, own, addressString] {
			    removeReaction(addressString);
			    setOwnReaction(own);
		    });
	    });

	mChatMessageModelConnection->makeConnectToModel(
	    &ChatMessageModel::msgStateChanged,
	    [this](const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state) {
		    auto imdnStatusList = computeDeliveryStatus(message);
		    auto msgState = LinphoneEnums::fromLinphone(state);
		    mChatMessageModelConnection->invokeToCore([this, msgState, imdnStatusList] {
			    setImdnStatusList(imdnStatusList);
			    setMessageState(msgState);
		    });
	    });
	mChatMessageModelConnection->makeConnectToModel(
	    &ChatMessageModel::fileTransferProgressIndication,
	    [this](const std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> &content,
	           size_t offset, size_t total) {
		    mChatMessageModelConnection->invokeToCore([this, content, offset, total] {
			    auto it =
			        std::find_if(mChatMessageContentList.begin(), mChatMessageContentList.end(),
			                     [content](QSharedPointer<ChatMessageContentCore> item) {
				                     return item->getContentModel()->getContent()->getName() == content->getName();
			                     });
			    if (it != mChatMessageContentList.end()) {
				    auto contentCore = mChatMessageContentList.at(std::distance(mChatMessageContentList.begin(), it));
				    assert(contentCore);
				    contentCore->setFileOffset(offset);
			    }
		    });
	    });

	mChatMessageModelConnection->makeConnectToModel(
	    &ChatMessageModel::fileTransferTerminated, [this](const std::shared_ptr<linphone::ChatMessage> &message,
	                                                      const std::shared_ptr<linphone::Content> &content) {
		    mChatMessageModelConnection->invokeToCore([this, content] {
			    auto it =
			        std::find_if(mChatMessageContentList.begin(), mChatMessageContentList.end(),
			                     [content](QSharedPointer<ChatMessageContentCore> item) {
				                     return item->getContentModel()->getContent()->getName() == content->getName();
			                     });
			    if (it != mChatMessageContentList.end()) {
				    auto contentCore = mChatMessageContentList.at(std::distance(mChatMessageContentList.begin(), it));
				    assert(contentCore);
				    contentCore->setWasDownloaded(true);
			    }
		    });
	    });
	mChatMessageModelConnection->makeConnectToModel(
	    &ChatMessageModel::fileTransferRecv,
	    [this](const std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> &content,
	           const std::shared_ptr<const linphone::Buffer> &buffer) { lInfo() << log().arg("transfer received"); });
	mChatMessageModelConnection->makeConnectToModel(
	    &ChatMessageModel::fileTransferSend,
	    [this](const std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> &content,
	           size_t offset, size_t size) { lInfo() << log().arg("transfer send"); });
	mChatMessageModelConnection->makeConnectToModel(
	    &ChatMessageModel::fileTransferSendChunk,
	    [this](const std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> &content,
	           size_t offset, size_t size,
	           const std::shared_ptr<linphone::Buffer> &buffer) { lInfo() << log().arg("transfer send chunk"); });
	mChatMessageModelConnection->makeConnectToModel(
	    &ChatMessageModel::participantImdnStateChanged,
	    [this](const std::shared_ptr<linphone::ChatMessage> &message,
	           const std::shared_ptr<const linphone::ParticipantImdnState> &state) {
		    auto imdnStatusList = computeDeliveryStatus(message);
		    mChatMessageModelConnection->invokeToCore([this, imdnStatusList] { setImdnStatusList(imdnStatusList); });
	    });
	mChatMessageModelConnection->makeConnectToModel(
	    &ChatMessageModel::ephemeralMessageTimeUpdated,
	    [this](const std::shared_ptr<linphone::ChatMessage> &message, int expireTime) {
		    auto now = QDateTime::currentDateTime();
		    int duration = now.secsTo(QDateTime::fromSecsSinceEpoch(expireTime));
		    mChatMessageModelConnection->invokeToCore([this, duration] { setEphemeralDuration(duration); });
	    });
}

QList<ImdnStatus> ChatMessageCore::computeDeliveryStatus(const std::shared_ptr<linphone::ChatMessage> &message) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	QList<ImdnStatus> imdnStatusList;
	auto createImdnStatus = [this](std::shared_ptr<linphone::ParticipantImdnState> participant,
	                               linphone::ChatMessage::State state) -> ImdnStatus {
		auto address = participant->getParticipant() ? participant->getParticipant()->getAddress()->clone() : nullptr;
		auto lastUpdated = QDateTime::fromSecsSinceEpoch(participant->getStateChangeTime());
		if (address) {
			address->clean();
			auto addrString = Utils::coreStringToAppString(address->asStringUriOnly());
			auto imdn =
			    ImdnStatus::createMessageImdnStatusVariant(addrString, LinphoneEnums::fromLinphone(state), lastUpdated);
			return imdn;
		}
		return ImdnStatus();
	};

	// Read
	for (auto &participant : message->getParticipantsByImdnState(linphone::ChatMessage::State::Displayed)) {
		auto imdn = createImdnStatus(participant, linphone::ChatMessage::State::Displayed);
		imdnStatusList.append(imdn);
	}
	// Received
	for (auto &participant : message->getParticipantsByImdnState(linphone::ChatMessage::State::DeliveredToUser)) {
		auto imdn = createImdnStatus(participant, linphone::ChatMessage::State::DeliveredToUser);
		imdnStatusList.append(imdn);
	}
	// Sent
	for (auto &participant : message->getParticipantsByImdnState(linphone::ChatMessage::State::Delivered)) {
		auto imdn = createImdnStatus(participant, linphone::ChatMessage::State::Delivered);
		imdnStatusList.append(imdn);
	}
	// Error
	for (auto &participant : message->getParticipantsByImdnState(linphone::ChatMessage::State::NotDelivered)) {
		auto imdn = createImdnStatus(participant, linphone::ChatMessage::State::NotDelivered);
		imdnStatusList.append(imdn);
	}
	return imdnStatusList;
}

QDateTime ChatMessageCore::getTimestamp() const {
	return mTimestamp;
}

QString ChatMessageCore::getText() const {
	return mText;
}

void ChatMessageCore::setText(QString text) {
	if (mText != text) {
		mText = text;
		emit textChanged(text);
	}
}

QString ChatMessageCore::getPeerAddress() const {
	return mPeerAddress;
}

QString ChatMessageCore::getPeerName() const {
	return mPeerName;
}

QString ChatMessageCore::getFromAddress() const {
	return mFromAddress;
}

QString ChatMessageCore::getFromName() const {
	return mFromName;
}

QString ChatMessageCore::getToAddress() const {
	return mToAddress;
}

QString ChatMessageCore::getToName() const {
	return mToName;
}

QString ChatMessageCore::getMessageId() const {
	return mMessageId;
}
bool ChatMessageCore::isRemoteMessage() const {
	return mIsRemoteMessage;
}

bool ChatMessageCore::isFromChatGroup() const {
	return mIsFromChatGroup;
}

bool ChatMessageCore::isEphemeral() const {
	return mIsEphemeral;
}

int ChatMessageCore::getEphemeralDuration() const {
	return mEphemeralDuration;
}

void ChatMessageCore::setEphemeralDuration(int duration) {
	if (mEphemeralDuration != duration) {
		mEphemeralDuration = duration;
		emit ephemeralDurationChanged(duration);
	}
}

bool ChatMessageCore::hasFileContent() const {
	return mHasFileContent;
}

bool ChatMessageCore::isRead() const {
	return mIsRead;
}

void ChatMessageCore::setIsRead(bool read) {
	if (mIsRead != read) {
		mIsRead = read;
		emit isReadChanged(read);
	}
}

QString ChatMessageCore::getOwnReaction() const {
	return mOwnReaction;
}

void ChatMessageCore::setOwnReaction(const QString &reaction) {
	if (mOwnReaction != reaction) {
		mOwnReaction = reaction;
		emit messageReactionChanged();
	}
}

QString ChatMessageCore::getTotalReactionsLabel() const {
	return mTotalReactionsLabel;
}

QList<Reaction> ChatMessageCore::getReactions() const {
	return mReactions;
}

QList<QVariant> ChatMessageCore::getReactionsSingleton() const {
	return mReactionsSingletonMap;
}

QStringList ChatMessageCore::getReactionsSingletonAsStrings() const {
	QStringList reacStringList;
	int totalCount = 0;
	for (auto &reac : mReactionsSingletonMap) {
		auto map = reac.toMap();
		auto count = map["count"].toInt();
		totalCount += count;
		reacStringList.append(QString("%1 %2").arg(map["body"].toString()).arg(count));
	}
	reacStringList.prepend(QString("%1 %2").arg(mTotalReactionsLabel).arg(totalCount));
	return reacStringList;
}

QList<QSharedPointer<ChatMessageContentCore>> ChatMessageCore::getChatMessageContentList() const {
	return mChatMessageContentList;
}

void ChatMessageCore::setReactions(const QList<Reaction> &reactions) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	mReactions = reactions;
	emit messageReactionChanged();
}

void ChatMessageCore::resetReactionsSingleton() {
	mReactionsSingletonMap.clear();
	for (auto &reac : mReactions) {
		auto it = std::find_if(mReactionsSingletonMap.begin(), mReactionsSingletonMap.end(),
		                       [body = reac.mBody](QVariant data) {
			                       auto dataBody = data.toMap()["body"].toString();
			                       return body == dataBody;
		                       });
		if (it == mReactionsSingletonMap.end())
			mReactionsSingletonMap.push_back(createReactionSingletonVariant(reac.mBody, 1));
		else {
			auto map = it->toMap();
			auto count = map["count"].toInt();
			++count;
			map.remove("count");
			map.insert("count", count);
			mReactionsSingletonMap.erase(it);
			mReactionsSingletonMap.push_back(map);
		}
	}
	emit singletonReactionMapChanged();
}

void ChatMessageCore::removeReaction(const Reaction &reaction) {
	int i = 0;
	for (const auto &r : mReactions) {
		if (reaction == r) {
			mReactions.removeAt(i);
			emit messageReactionChanged();
		}
		++i;
	}
}

void ChatMessageCore::removeOneReactionFromSingletonMap(const QString &body) {
	auto it = std::find_if(mReactionsSingletonMap.begin(), mReactionsSingletonMap.end(), [body](QVariant data) {
		auto dataBody = data.toMap()["body"].toString();
		return body == dataBody;
	});
	if (it != mReactionsSingletonMap.end()) {
		auto map = it->toMap();
		auto count = map["count"].toInt();
		if (count <= 1) mReactionsSingletonMap.erase(it);
		else {
			--count;
			map.remove("count");
			map.insert("count", count);
		}
		emit messageReactionChanged();
	}
}

void ChatMessageCore::removeReaction(const QString &address) {
	int n = mReactions.removeIf([address, this](Reaction r) {
		if (r.mAddress == address) {
			removeOneReactionFromSingletonMap(r.mBody);
			return true;
		}
		return false;
	});
	if (n > 0) emit messageReactionChanged();
}

LinphoneEnums::ChatMessageState ChatMessageCore::getMessageState() const {
	return mMessageState;
}

void ChatMessageCore::setMessageState(LinphoneEnums::ChatMessageState state) {
	if (mMessageState != state) {
		mMessageState = state;
		emit messageStateChanged();
	}
}

QList<ImdnStatus> ChatMessageCore::getImdnStatusList() const {
	return mImdnStatusList;
}

void ChatMessageCore::setImdnStatusList(QList<ImdnStatus> status) {
	mImdnStatusList = status;
	emit imdnStatusListChanged();
}

QStringList ChatMessageCore::getImdnStatusListLabels() const {
	QStringList statusList;
	int count = 0;
	auto imdnSingletons = getImdnStatusAsSingletons();
	for (auto &status : imdnSingletons) {
		auto map = status.toMap();
		auto val = map["state"].value<LinphoneEnums::ChatMessageState>();
		auto count = map["count"].toInt();
		statusList.append(QString("%1 %2").arg(LinphoneEnums::toString(val)).arg(count));
	}
	return statusList;
}

QVariantList ChatMessageCore::getImdnStatusAsSingletons() const {
	QVariantList statusSingletons;
	statusSingletons.append(createImdnStatusSingletonVariant(LinphoneEnums::ChatMessageState::StateDisplayed, 0));
	statusSingletons.append(createImdnStatusSingletonVariant(LinphoneEnums::ChatMessageState::StateDeliveredToUser, 0));
	statusSingletons.append(createImdnStatusSingletonVariant(LinphoneEnums::ChatMessageState::StateDelivered, 0));
	statusSingletons.append(createImdnStatusSingletonVariant(LinphoneEnums::ChatMessageState::StateNotDelivered, 0));
	for (auto &stat : mImdnStatusList) {
		auto it = std::find_if(statusSingletons.begin(), statusSingletons.end(), [state = stat.mState](QVariant data) {
			auto dataState = data.toMap()["state"].value<LinphoneEnums::ChatMessageState>();
			return state == dataState;
		});
		if (it == statusSingletons.end()) {
			if (!stat.mAddress.isEmpty()) statusSingletons.append(createImdnStatusSingletonVariant(stat.mState, 1));
		} else {
			auto map = it->toMap();
			auto count = map["count"].toInt();
			++count;
			map.remove("count");
			map.insert("count", count);
			int index = std::distance(statusSingletons.begin(), it);
			statusSingletons.replace(index, map);
		}
	}
	return statusSingletons;
}

std::shared_ptr<ChatMessageModel> ChatMessageCore::getModel() const {
	return mChatMessageModel;
}

// ConferenceInfoGui *ChatMessageCore::getConferenceInfoGui() const {
// 	return mConferenceInfo ? new ConferenceInfoGui(mConferenceInfo) : nullptr;
// }

ChatMessageContentGui *ChatMessageCore::getVoiceRecordingContent() const {
	return new ChatMessageContentGui(mVoiceRecordingContent);
}