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
/*
class Thumbnail{
public:
	Thumbnail();
	QString mId;
	QString mPath;
	
	QString toString()const;
	void fromString(const QString& );
	static QString toString(const QVector<Thumbnail>& );
	static QVector<Thumbnail> fromListString(const QString& );
};
*/
#include "components/chat-room/ChatRoomModel.hpp"
#include "ChatEvent.hpp"
#include "components/participant-imdn/ParticipantImdnStateListModel.hpp"

class ChatMessageModel;
class ParticipantImdnStateProxyModel;
class ParticipantImdnStateListModel;

class ContentModel : public QObject{
	Q_OBJECT
public:
	ContentModel(ChatMessageModel* chatModel);
	ContentModel(std::shared_ptr<linphone::Content> content, ChatMessageModel* chatModel);
	
	Q_PROPERTY(quint64 fileSize READ getFileSize NOTIFY fileSizeChanged)
	Q_PROPERTY(QString name READ getName NOTIFY nameChanged)
	Q_PROPERTY(quint64 fileOffset MEMBER mFileOffset WRITE setFileOffset NOTIFY fileOffsetChanged)
	
	Q_PROPERTY(QString thumbnail READ getThumbnail WRITE setThumbnail NOTIFY thumbnailChanged)
	Q_PROPERTY(bool wasDownloaded MEMBER mWasDownloaded WRITE setWasDownloaded NOTIFY wasDownloadedChanged)
	
	std::shared_ptr<linphone::Content> getContent()const;	
	
	quint64 getFileSize() const;
	QString getName() const;
	QString getThumbnail() const;
	
	void setFileOffset(quint64 fileOffset);
	void setThumbnail(const QString& data);
	void setWasDownloaded(bool wasDownloaded);
	void setContent(std::shared_ptr<linphone::Content> content);
	
	void createThumbnail ();
	Q_INVOKABLE void downloadFile();
	Q_INVOKABLE void openFile (bool showDirectory = false);	
	
	
	QString mThumbnail;
	bool mWasDownloaded;
	quint64 mFileOffset;
	
signals:
	void fileSizeChanged();
	void nameChanged();
	void thumbnailChanged();
	void fileOffsetChanged();
	void wasDownloadedChanged();
	
private:
	std::shared_ptr<linphone::Content> mContent;
	ChatMessageModel* mChatMessageModel;
};
Q_DECLARE_METATYPE(std::shared_ptr<ContentModel>)

class ChatMessageListener : public QObject, public linphone::ChatMessageListener {
Q_OBJECT
public:
	ChatMessageListener(ChatMessageModel * model, QObject * parent = nullptr);
	virtual ~ChatMessageListener(){}
	
	virtual void onFileTransferRecv(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, const std::shared_ptr<const linphone::Buffer> & buffer) override;
	virtual void onFileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size, const std::shared_ptr<linphone::Buffer> & buffer) override;
	virtual std::shared_ptr<linphone::Buffer> onFileTransferSend(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size) override;
	virtual void onFileTransferProgressIndication (const std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> &, size_t offset, size_t) override;
	virtual void onMsgStateChanged (const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state) override;
	virtual void onParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state) override;
	virtual void onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatMessage> & message) override;
	virtual void onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatMessage> & message) override;
signals:
	void fileTransferRecv(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, const std::shared_ptr<const linphone::Buffer> & buffer);
	void fileTransferSendChunk(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<linphone::Content> & content, size_t offset, size_t size, const std::shared_ptr<linphone::Buffer> & buffer);
	std::shared_ptr<linphone::Buffer> fileTransferSend (const std::shared_ptr<linphone::ChatMessage> &,const std::shared_ptr<linphone::Content> &,size_t,size_t);
	void fileTransferProgressIndication (const std::shared_ptr<linphone::ChatMessage> &message, const std::shared_ptr<linphone::Content> &, size_t offset, size_t);
	void msgStateChanged (const std::shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state);
	void participantImdnStateChanged(const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state);
	void ephemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatMessage> & message);
	void ephemeralMessageDeleted(const std::shared_ptr<linphone::ChatMessage> & message);
};

class ChatMessageModel : public QObject, public ChatEvent {
	Q_OBJECT
public:
	static std::shared_ptr<ChatMessageModel> create(std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent = nullptr);// Call it instead constructor
	ChatMessageModel (std::shared_ptr<linphone::ChatMessage> chatMessage, QObject * parent = nullptr);
	virtual ~ChatMessageModel();
	
	class AppDataManager{// Used to manage appdata to store persistant data like created thumbnails
	public:
		AppDataManager(const QString&);
		QMap<QString, QString> mData;// Path / ID
		
		QString toString();
	};
	
	
	Q_PROPERTY(QString fromDisplayName READ getFromDisplayName CONSTANT)
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
	//Q_PROPERTY(QString thumbnail MEMBER mThumbnail NOTIFY thumbnailChanged)
	Q_PROPERTY(QString content MEMBER mContent NOTIFY contentChanged)
	
	Q_PROPERTY(ContentModel * fileContentModel READ getFileContentModel NOTIFY fileContentChanged)
	//Q_PROPERTY(QList<ContentModel *> contents READ getContents CONSTANT)
	
	std::shared_ptr<linphone::ChatMessage> getChatMessage();
	std::shared_ptr<ContentModel> getContentModel(std::shared_ptr<linphone::Content> content);
	Q_INVOKABLE ContentModel * getContent(int i);
	
	//----------------------------------------------------------------------------
	
	QString getFromDisplayName() const;
	QString getFromSipAddress() const;
	QString getToDisplayName() const;
	QString getToSipAddress() const;
	ContactModel * getContactModel() const;
	bool isEphemeral() const;
	Q_INVOKABLE qint64 getEphemeralExpireTime() const;
	Q_INVOKABLE long getEphemeralLifetime() const;
	LinphoneEnums::ChatMessageState getState() const;
	bool isOutgoing() const;
	ContentModel * getFileContentModel() const;
	QList<ContentModel*> getContents() const;
	Q_INVOKABLE ParticipantImdnStateProxyModel * getProxyImdnStates();
	std::shared_ptr<ParticipantImdnStateListModel> getParticipantImdnStates() const;
	
	//----------------------------------------------------------------------------
	
	void setWasDownloaded(bool wasDownloaded);
	
	//----------------------------------------------------------------------------	
	
	Q_INVOKABLE void resendMessage ();
	
	virtual void deleteEvent();
	void updateFileTransferInformation();
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
	QList<std::shared_ptr<ContentModel>> mContents;
	std::shared_ptr<ContentModel> mFileTransfertContent;
	std::shared_ptr<linphone::ChatMessage> mChatMessage;
	std::shared_ptr<ParticipantImdnStateListModel> mParticipantImdnStateListModel;
	std::shared_ptr<ChatMessageListener> mChatMessageListener;
};

Q_DECLARE_METATYPE(std::shared_ptr<ChatMessageModel>)
Q_DECLARE_METATYPE(ChatMessageListener*)
#endif
