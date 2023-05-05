/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef CHAT_MESSAGE_MODEL_H
#define CHAT_MESSAGE_MODEL_H

#include "utils/LinphoneEnums.hpp"

#include <QDateTime>

// =============================================================================

#include "components/chat-room/ChatRoomModel.hpp"
#include "ChatEvent.hpp"
#include "components/participant-imdn/ParticipantImdnStateListModel.hpp"

class ChatMessageModel;
class ChatMessageListener;
class ParticipantImdnStateProxyModel;
class ParticipantImdnStateListModel;
class ContentModel;
class ContentListModel;
class ContentProxyModel;

class ChatMessageModel : public ChatEvent {
	Q_OBJECT
public:
	static QSharedPointer<ChatMessageModel> create(std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent = nullptr);// Call it instead constructor
	ChatMessageModel (std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent = nullptr);
	virtual ~ChatMessageModel();
	
	Q_PROPERTY(QString fromDisplayName READ getFromDisplayName CONSTANT)
	Q_PROPERTY(QString fromDisplayNameReplyMessage READ getFromDisplayNameReplyMessage CONSTANT)
	Q_PROPERTY(QString fromSipAddress READ getFromSipAddress CONSTANT)
	Q_PROPERTY(QString toDisplayName READ getToDisplayName CONSTANT)
	Q_PROPERTY(QString toSipAddress READ getToSipAddress CONSTANT)
	Q_PROPERTY(ContactModel * contactModel READ getContactModel CONSTANT)
	
	Q_PROPERTY(bool isEphemeral READ isEphemeral NOTIFY isEphemeralChanged)
	Q_PROPERTY(qint64 ephemeralExpireTime READ getEphemeralExpireTime NOTIFY ephemeralExpireTimeChanged)
	Q_PROPERTY(long ephemeralLifetime READ getEphemeralLifetime CONSTANT)	
	Q_PROPERTY(LinphoneEnums::ChatMessageState state READ getState NOTIFY stateChanged)
	Q_PROPERTY(bool isOutgoing READ isOutgoing NOTIFY isOutgoingChanged)
	
	Q_PROPERTY(bool wasDownloaded MEMBER mWasDownloaded WRITE setWasDownloaded NOTIFY wasDownloadedChanged)
	Q_PROPERTY(ChatRoomModel::EntryType type MEMBER mType CONSTANT)
	Q_PROPERTY(QDateTime timestamp MEMBER mTimestamp CONSTANT)
	Q_PROPERTY(QDateTime receivedTimestamp MEMBER mReceivedTimestamp CONSTANT)
	Q_PROPERTY(QString content MEMBER mContent NOTIFY contentChanged)
	
	
	Q_PROPERTY(bool isReply READ isReply CONSTANT)
	Q_PROPERTY(ChatMessageModel* replyChatMessageModel READ getReplyChatMessageModel CONSTANT)
	
	Q_PROPERTY(bool isForward READ isForward CONSTANT)
	Q_PROPERTY(QString getForwardInfo READ getForwardInfo CONSTANT)
	Q_PROPERTY(QString getForwardInfoDisplayName READ getForwardInfoDisplayName CONSTANT)
	
	
	std::shared_ptr<linphone::ChatMessage> getChatMessage();
	QSharedPointer<ContentModel> getContentModel(std::shared_ptr<linphone::Content> content);
	
	//----------------------------------------------------------------------------
	
	QString getFromDisplayName() const;
	QString getFromDisplayNameReplyMessage() const;
	QString getFromSipAddress() const;
	QString getToDisplayName() const;
	QString getToSipAddress() const;
	ContactModel * getContactModel() const;
	bool isEphemeral() const;
	Q_INVOKABLE qint64 getEphemeralExpireTime() const;
	Q_INVOKABLE long getEphemeralLifetime() const;
	LinphoneEnums::ChatMessageState getState() const;
	bool isOutgoing() const;
	Q_INVOKABLE ParticipantImdnStateProxyModel * getProxyImdnStates();
	QSharedPointer<ParticipantImdnStateListModel> getParticipantImdnStates() const;
	QSharedPointer<ContentListModel> getContents() const;
	
	bool isReply() const;
	ChatMessageModel * getReplyChatMessageModel() const;
	
	bool isForward() const;
	QString getForwardInfo() const;
	QString getForwardInfoDisplayName() const;
	
	//----------------------------------------------------------------------------
	
	void setWasDownloaded(bool wasDownloaded);
	virtual void setTimestamp(const QDateTime& timestamp = QDateTime::currentDateTime()) override;
	virtual void setReceivedTimestamp(const QDateTime& timestamp = QDateTime::currentDateTime()) override;
	
	//----------------------------------------------------------------------------
	
	Q_INVOKABLE void resendMessage ();
	
	virtual void deleteEvent() override;
	void updateFileTransferInformation();
	static QDateTime initReceivedTimestamp(const std::shared_ptr<linphone::ChatMessage> &message); // return received timestamp
	
	//		Linphone callbacks  
	void onFileTransferRecv(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, const std::shared_ptr<const linphone::Buffer> & buffer) ;
	void onFileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size, const std::shared_ptr<linphone::Buffer> & buffer) ;
	std::shared_ptr<linphone::Buffer> onFileTransferSend (const std::shared_ptr<linphone::ChatMessage> &,const std::shared_ptr<linphone::Content> &,size_t,size_t);
	void onFileTransferProgressIndication (const std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> &, size_t offset, size_t);
	void onMsgStateChanged (const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state);
	void onParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state);	
	void onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatMessage> & message);
	void onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatMessage> & message);
	
	//----------------------------------------------------------------------------
	bool mWasDownloaded;
	QString mContent;
	QString mIsOutgoing;
	//----------------------------------------------------------------------------
	
signals:
	void isEphemeralChanged();
	void ephemeralExpireTimeChanged();
	void stateChanged();
	void wasDownloadedChanged();
	void contentChanged();
	void isOutgoingChanged();
	void fileContentChanged();
	void remove(ChatMessageModel* model);
	
	
private:
	void connectTo(ChatMessageListener * listener);

	std::shared_ptr<linphone::ChatMessage> mChatMessage;
	std::shared_ptr<ChatMessageListener> mChatMessageListener;	// This is passed to linpĥone object and must be in shared_ptr
	
	QSharedPointer<ContentListModel> mContentListModel;
	QSharedPointer<ContentModel> mFileTransfertContent;
	QSharedPointer<ParticipantImdnStateListModel> mParticipantImdnStateListModel;
	QSharedPointer<ChatMessageModel> mReplyChatMessageModel;
};
Q_DECLARE_METATYPE(ChatMessageModel*)
Q_DECLARE_METATYPE(QSharedPointer<ChatMessageModel>)
#endif
