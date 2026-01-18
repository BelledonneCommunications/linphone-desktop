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

#ifndef CHAT_MESSAGE_CONTENT_CORE_H_
#define CHAT_MESSAGE_CONTENT_CORE_H_

#include "core/conference/ConferenceInfoCore.hpp"
#include "core/conference/ConferenceInfoGui.hpp"
#include "model/chat/message/content/ChatMessageContentModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>

#include <linphone++/linphone.hh>

class ChatMessageContentCore : public QObject, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(QString name READ getName CONSTANT)
	Q_PROPERTY(quint64 fileOffset READ getFileOffset WRITE setFileOffset NOTIFY fileOffsetChanged)

	Q_PROPERTY(QUrl thumbnail READ getThumbnail WRITE setThumbnail NOTIFY thumbnailChanged)
	Q_PROPERTY(bool wasDownloaded READ wasDownloaded WRITE setWasDownloaded NOTIFY wasDownloadedChanged)
	Q_PROPERTY(QString filePath READ getFilePath WRITE setFilePath NOTIFY filePathChanged)
	Q_PROPERTY(QString utf8Text READ getUtf8Text CONSTANT)
	Q_PROPERTY(QString richFormatText WRITE setRichFormatText MEMBER mRichFormatText NOTIFY richFormatTextChanged)
	Q_PROPERTY(QString searchTextPart READ getSearchedTextPart WRITE setSearchedTextPart NOTIFY searchedTextPartChanged)
	Q_PROPERTY(bool isFile READ isFile WRITE setIsFile NOTIFY isFileChanged)
	Q_PROPERTY(bool isFileEncrypted READ isFileEncrypted WRITE setIsFileEncrypted NOTIFY isFileEncryptedChanged)
	Q_PROPERTY(bool isFileTransfer READ isFileTransfer WRITE setIsFileTransfer NOTIFY isFileTransferChanged)
	Q_PROPERTY(bool isCalendar READ isCalendar CONSTANT)
	Q_PROPERTY(ConferenceInfoGui *conferenceInfo READ getConferenceInfoGui CONSTANT)
	Q_PROPERTY(bool isMultipart READ isMultipart CONSTANT)
	Q_PROPERTY(bool isText READ isText CONSTANT)
	Q_PROPERTY(bool isVideo READ isVideo NOTIFY isVideoChanged)
	Q_PROPERTY(bool isVoiceRecording READ isVoiceRecording CONSTANT)
	Q_PROPERTY(int fileDuration READ getFileDuration CONSTANT)
	Q_PROPERTY(quint64 fileSize READ getFileSize CONSTANT)

public:
	static QSharedPointer<ChatMessageContentCore> create(const std::shared_ptr<linphone::Content> &content,
	                                                     std::shared_ptr<ChatMessageModel> chatMessageModel);
	ChatMessageContentCore(const std::shared_ptr<linphone::Content> &content,
	                       std::shared_ptr<ChatMessageModel> chatMessageModel);
	~ChatMessageContentCore();
	void setSelf(QSharedPointer<ChatMessageContentCore> me);

	bool isFile() const;
	void setIsFile(bool isFile);
	bool isFileEncrypted() const;
	void setIsFileEncrypted(bool isFileEncrypted);
	bool isFileTransfer() const;
	void setIsFileTransfer(bool isFileTransfer);

	bool isVideo() const;
	bool isCalendar() const;
	bool isMultipart() const;
	bool isText() const;
	bool isVoiceRecording() const;

	QString getUtf8Text() const;
	QString getName() const;
	quint64 getFileSize() const;
	quint64 getFileOffset() const;
	void setFileOffset(quint64 fileOffset);
	QString getFilePath() const;
	void setFilePath(QString path);
	int getFileDuration() const;
	ConferenceInfoGui *getConferenceInfoGui() const;

	void setThumbnail(const QUrl &data);
	QUrl getThumbnail() const;

	bool wasDownloaded() const;
	void setWasDownloaded(bool downloaded);

	void setRichFormatText(const QString &richFormatText);
	Q_INVOKABLE void setSearchedTextPart(const QString &searchedTextPart);
	QString getSearchedTextPart() const;

	const std::shared_ptr<ChatMessageContentModel> &getContentModel() const;

signals:
	void msgStateChanged(LinphoneEnums::ChatMessageState state);
	void thumbnailChanged();
	void fileOffsetChanged();
	void filePathChanged();
	void isFileChanged();
	void isFileTransferChanged();
	void isFileEncryptedChanged();
	void wasDownloadedChanged(bool downloaded);
	void isVideoChanged();
	void searchedTextPartChanged();
	void richFormatTextChanged();

	void lCreateThumbnail(const bool &force = false);
	void lRemoveDownloadedFile();
	void lDownloadFile();
	void lCancelDownloadFile();
	void lOpenFile(bool showDirectory = false);
	bool lSaveAs(const QString &path);

private:
	DECLARE_ABSTRACT_OBJECT
	bool mIsFile;
	bool mIsVideo;
	bool mIsFileEncrypted;
	bool mIsFileTransfer;
	bool mIsCalendar;
	bool mIsMultipart;
	bool mIsText;
	bool mIsVoiceRecording;
	int mFileDuration;
	QUrl mThumbnail;
	QString mUtf8Text;
	QString mRichFormatText;
	QString mSearchedTextPart;
	QString mFilePath;
	QString mName;
	quint64 mFileSize;
	quint64 mFileOffset;
	bool mWasDownloaded;
	QSharedPointer<ConferenceInfoCore> mConferenceInfo = nullptr;

	std::shared_ptr<ChatMessageContentModel> mChatMessageContentModel;
	QSharedPointer<SafeConnection<ChatMessageContentCore, ChatMessageContentModel>> mChatMessageContentModelConnection;
};

#endif // CHAT_MESSAGE_CONTENT_CORE_H_
