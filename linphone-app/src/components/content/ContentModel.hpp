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

#ifndef CONTENT_MODEL_H_
#define CONTENT_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include <QSharedPointer>

#include "components/chat-events/ChatMessageModel.hpp"
class ChatMessageModel;
class ConferenceInfoModel;

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
	Q_PROPERTY(QString filePath READ getFilePath CONSTANT)
	Q_PROPERTY(ChatMessageModel * chatMessageModel READ getChatMessageModel CONSTANT)
	Q_PROPERTY(ConferenceInfoModel * conferenceInfoModel READ getConferenceInfoModel CONSTANT)
	Q_PROPERTY(QString text READ getUtf8Text CONSTANT)
	
	std::shared_ptr<linphone::Content> getContent()const;
	ChatMessageModel * getChatMessageModel()const;
	
	quint64 getFileSize() const;
	QString getName() const;
	QString getThumbnail() const;
	QString getFilePath() const;
	QString getUtf8Text() const;
	ConferenceInfoModel * getConferenceInfoModel();//Create a conference Info if not set
	
	void setFileOffset(quint64 fileOffset);
	void setThumbnail(const QString& data);
	void setWasDownloaded(bool wasDownloaded);
	void setContent(std::shared_ptr<linphone::Content> content);
	
	Q_INVOKABLE bool isFile() const;
	Q_INVOKABLE bool isFileEncrypted() const;
	Q_INVOKABLE bool isFileTransfer() const;
	Q_INVOKABLE bool isIcalendar() const;
	Q_INVOKABLE bool isMultipart() const;
	Q_INVOKABLE bool isText() const;
	Q_INVOKABLE bool isVoiceRecording()const;
	
	Q_INVOKABLE int getFileDuration() const;
	
	void createThumbnail (const bool& force = false);
	void removeDownloadedFile();
	
	Q_INVOKABLE void downloadFile();
	Q_INVOKABLE void cancelDownloadFile();
	Q_INVOKABLE void openFile (bool showDirectory = false);
	Q_INVOKABLE bool saveAs (const QString& path);
	
	
	QString mThumbnail;
	bool mWasDownloaded;
	quint64 mFileOffset;
public slots:
	void updateTransferData();
	
signals:
	void fileSizeChanged();
	void nameChanged();
	void thumbnailChanged();
	void fileOffsetChanged();
	void wasDownloadedChanged();
	
private:
	std::shared_ptr<linphone::Content> mContent;
	ChatMessageModel* mChatMessageModel;
	ChatMessageModel::AppDataManager mAppData;	// Used if there is no Chat Message model set.
	QSharedPointer<ConferenceInfoModel> mConferenceInfoModel;
};
Q_DECLARE_METATYPE(QSharedPointer<ContentModel>)

#endif
