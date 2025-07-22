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

#ifndef CHAT_MESSAGE_CORE_H_
#define CHAT_MESSAGE_CORE_H_

#include "EventLogCore.hpp"
#include "core/chat/message/content/ChatMessageContentGui.hpp"
#include "core/chat/message/content/ChatMessageContentProxy.hpp"
#include "core/conference/ConferenceInfoCore.hpp"
#include "core/conference/ConferenceInfoGui.hpp"
#include "model/chat/message/ChatMessageModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>

#include <linphone++/linphone.hh>

struct ImdnStatus {
	Q_GADGET

	Q_PROPERTY(QString address MEMBER mAddress)
	Q_PROPERTY(LinphoneEnums::ChatMessageState state MEMBER mState)
	Q_PROPERTY(QDateTime lastUpdatedTime MEMBER mLastUpdatedTime)

public:
	QString mAddress;
	LinphoneEnums::ChatMessageState mState;
	QDateTime mLastUpdatedTime;

	ImdnStatus(const QString &address, const LinphoneEnums::ChatMessageState &state, QDateTime mLastUpdatedTime);
	ImdnStatus();
	ImdnStatus operator=(ImdnStatus r);
	bool operator==(const ImdnStatus &r) const;
	bool operator!=(ImdnStatus r);
	static ImdnStatus createMessageImdnStatusVariant(const QString &address,
	                                                 const LinphoneEnums::ChatMessageState &state,
	                                                 QDateTime mLastUpdatedTime);
};

struct Reaction {
	Q_GADGET

	Q_PROPERTY(QString body MEMBER mBody)
	Q_PROPERTY(QString address MEMBER mAddress)

public:
	QString mBody;
	QString mAddress;

	Reaction operator=(Reaction r);
	bool operator==(const Reaction &r) const;
	bool operator!=(Reaction r);
	static Reaction createMessageReactionVariant(const QString &body, const QString &address);
};

class ChatCore;
class EventLogCore;

class ChatMessageCore : public QObject, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(QDateTime timestamp READ getTimestamp WRITE setTimestamp NOTIFY timestampChanged)
	Q_PROPERTY(QString text READ getText WRITE setText NOTIFY textChanged)
	Q_PROPERTY(QString utf8Text MEMBER mUtf8Text CONSTANT)
	Q_PROPERTY(bool hasTextContent MEMBER mHasTextContent CONSTANT)
	Q_PROPERTY(QString peerAddress READ getPeerAddress CONSTANT)
	Q_PROPERTY(QString fromAddress READ getFromAddress CONSTANT)
	Q_PROPERTY(QString toAddress READ getToAddress CONSTANT)
	Q_PROPERTY(QString peerName READ getPeerName CONSTANT)
	Q_PROPERTY(QString fromName READ getFromName CONSTANT)
	Q_PROPERTY(QString totalReactionsLabel READ getTotalReactionsLabel CONSTANT)
	Q_PROPERTY(LinphoneEnums::ChatMessageState messageState READ getMessageState WRITE setMessageState NOTIFY
	               messageStateChanged)
	Q_PROPERTY(bool isRemoteMessage READ isRemoteMessage CONSTANT)
	Q_PROPERTY(bool isFromChatGroup READ isFromChatGroup CONSTANT)
	Q_PROPERTY(bool isEphemeral READ isEphemeral CONSTANT)
	Q_PROPERTY(
	    int ephemeralDuration READ getEphemeralDuration WRITE setEphemeralDuration NOTIFY ephemeralDurationChanged)
	Q_PROPERTY(bool isRead READ isRead WRITE setIsRead NOTIFY isReadChanged)
	Q_PROPERTY(QString ownReaction READ getOwnReaction WRITE setOwnReaction NOTIFY messageReactionChanged)
	Q_PROPERTY(QStringList imdnStatusListAsString READ getImdnStatusListLabels NOTIFY imdnStatusListChanged)
	Q_PROPERTY(QList<ImdnStatus> imdnStatusList READ getImdnStatusList NOTIFY imdnStatusListChanged)
	Q_PROPERTY(QList<QVariant> imdnStatusAsSingletons READ getImdnStatusAsSingletons NOTIFY imdnStatusListChanged)
	Q_PROPERTY(QList<Reaction> reactions READ getReactions WRITE setReactions NOTIFY messageReactionChanged)
	Q_PROPERTY(QList<QVariant> reactionsSingleton READ getReactionsSingleton NOTIFY singletonReactionMapChanged)
	Q_PROPERTY(
	    QStringList reactionsSingletonAsStrings READ getReactionsSingletonAsStrings NOTIFY singletonReactionMapChanged)
	Q_PROPERTY(bool isForward MEMBER mIsForward CONSTANT)
	Q_PROPERTY(bool isReply MEMBER mIsReply CONSTANT)
	Q_PROPERTY(QString replyText MEMBER mReplyText CONSTANT)
	Q_PROPERTY(QString repliedToName MEMBER mRepliedToName CONSTANT)
	Q_PROPERTY(bool hasFileContent MEMBER mHasFileContent CONSTANT)
	Q_PROPERTY(bool isVoiceRecording MEMBER mIsVoiceRecording CONSTANT)
	Q_PROPERTY(bool isCalendarInvite MEMBER mIsCalendarInvite CONSTANT)

public:
	static QSharedPointer<ChatMessageCore> create(const std::shared_ptr<linphone::ChatMessage> &chatmessage);
	ChatMessageCore(const std::shared_ptr<linphone::ChatMessage> &chatmessage);
	~ChatMessageCore();
	void setSelf(QSharedPointer<ChatMessageCore> me);

	QList<ImdnStatus> computeDeliveryStatus(const std::shared_ptr<linphone::ChatMessage> &message);

	QDateTime getTimestamp() const;
	void setTimestamp(QDateTime timestamp);

	QString getText() const;
	void setText(QString text);

	QString getPeerAddress() const;
	QString getPeerName() const;
	QString getFromAddress() const;
	QString getFromName() const;
	QString getToAddress() const;
	QString getToName() const;
	QString getMessageId() const;

	bool isRemoteMessage() const;
	bool isFromChatGroup() const;
	bool isEphemeral() const;
	int getEphemeralDuration() const;
	void setEphemeralDuration(int duration);

	bool hasFileContent() const;

	bool isRead() const;
	void setIsRead(bool read);

	QString getOwnReaction() const;
	void setOwnReaction(const QString &reaction);
	QString getTotalReactionsLabel() const;
	QList<Reaction> getReactions() const;
	QList<QVariant> getReactionsSingleton() const;
	QStringList getReactionsSingletonAsStrings() const;
	QList<QSharedPointer<ChatMessageContentCore>> getChatMessageContentList() const;
	void removeOneReactionFromSingletonMap(const QString &body);
	void resetReactionsSingleton();
	void setReactions(const QList<Reaction> &reactions);
	void removeReaction(const Reaction &reaction);
	void removeReaction(const QString &address);

	LinphoneEnums::ChatMessageState getMessageState() const;
	void setMessageState(LinphoneEnums::ChatMessageState state);
	QList<ImdnStatus> getImdnStatusList() const;
	void setImdnStatusList(QList<ImdnStatus> status);
	QList<QVariant> getImdnStatusAsSingletons() const;
	QStringList getImdnStatusListLabels() const;

	std::shared_ptr<ChatMessageModel> getModel() const;
	Q_INVOKABLE ChatMessageContentGui *getVoiceRecordingContent() const;

signals:
	void timestampChanged(QDateTime timestamp);
	void textChanged(QString text);
	void utf8TextChanged(QString text);
	void isReadChanged(bool read);
	void isRemoteMessageChanged(bool isRemote);
	void messageStateChanged();
	void imdnStatusListChanged();
	void messageReactionChanged();
	void singletonReactionMapChanged();
	void ephemeralDurationChanged(int duration);

	void lDelete();
	void deleted();
	void lMarkAsRead();
	void readChanged();
	void lSendReaction(const QString &reaction);
	void lRemoveReaction();
	void lSend();

private:
	DECLARE_ABSTRACT_OBJECT
	QString mText;
	QString mUtf8Text;
	bool mHasTextContent;
	QString mPeerAddress;
	QString mFromAddress;
	QString mToAddress;
	QString mFromName;
	QString mToName;
	QString mPeerName;
	QString mMessageId;
	QString mOwnReaction;
	QList<Reaction> mReactions;
	QList<ImdnStatus> mImdnStatusList;
	QList<QVariant> mReactionsSingletonMap;
	QDateTime mTimestamp;
	bool mIsRemoteMessage = false;
	bool mIsFromChatGroup = false;
	bool mIsRead = false;
	bool mIsForward = false;
	bool mIsReply = false;
	QString mReplyText;
	QString mRepliedToName;
	bool mHasFileContent = false;
	bool mIsCalendarInvite = false;
	bool mIsVoiceRecording = false;
	bool mIsEphemeral = false;
	int mEphemeralDuration = 0;

	bool mIsOutgoing = false;
	QString mTotalReactionsLabel;
	LinphoneEnums::ChatMessageState mMessageState;
	QList<QSharedPointer<ChatMessageContentCore>> mChatMessageContentList;
	// for voice recording creation message
	QSharedPointer<ChatMessageContentCore> mVoiceRecordingContent;
	// QSharedPointer<ConferenceInfoCore> mConferenceInfo = nullptr;

	std::shared_ptr<ChatMessageModel> mChatMessageModel;
	QSharedPointer<SafeConnection<ChatMessageCore, ChatMessageModel>> mChatMessageModelConnection;
};

#endif // CHAT_MESSAGE_CORE_H_
