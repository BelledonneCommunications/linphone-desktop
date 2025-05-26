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

#ifndef CHAT_MESSAGE_CONTENT_MODEL_H_
#define CHAT_MESSAGE_CONTENT_MODEL_H_

#include "tool/AbstractObject.hpp"
#include <linphone++/linphone.hh>

// =============================================================================
#include <QDateTime>
#include <QObject>
#include <QSharedPointer>
#include <QString>

class ChatMessageModel;
class ConferenceInfoModel;

class ChatMessageContentModel : public QObject, public AbstractObject {
	Q_OBJECT
public:
	ChatMessageContentModel(std::shared_ptr<linphone::Content> content,
	                        std::shared_ptr<ChatMessageModel> chatMessageModel);
	~ChatMessageContentModel();

	QString getThumbnail() const;

	void setThumbnail(const QString &data);
	void setWasDownloaded(bool wasDownloaded);

	void createThumbnail();
	void removeDownloadedFile(QString filePath);

	void downloadFile(const QString &name);
	void cancelDownloadFile();
	void openFile(const QString &name, bool wasDownloaded, bool showDirectory = false);
	bool saveAs(const QString &path);

	const std::shared_ptr<linphone::Content> &getContent() const;

signals:
	void thumbnailChanged(QString thumbnail);
	void fileOffsetChanged();
	void wasDownloadedChanged(const std::shared_ptr<linphone::Content> &content, bool downloaded);
	void fileSavedChanged(bool success);
	void filePathChanged(const std::shared_ptr<linphone::Content> &content, QString filePath);
	void messageStateChanged(linphone::ChatMessage::State state);

private:
	DECLARE_ABSTRACT_OBJECT
	std::shared_ptr<linphone::Content> mContent;
	std::shared_ptr<ChatMessageModel> mChatMessageModel;
	QSharedPointer<ConferenceInfoModel> mConferenceInfoModel;
};

#endif