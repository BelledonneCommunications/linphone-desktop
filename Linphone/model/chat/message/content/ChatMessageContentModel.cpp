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

#include "ChatMessageContentModel.hpp"

#include <QDesktopServices>
#include <QMessageBox>
#include <QPainter>
#include <QQmlApplicationEngine>

#include "core/App.hpp"
#include "tool/providers/ExternalImageProvider.hpp"
#include "tool/providers/ThumbnailProvider.hpp"

#include "model/chat/message/ChatMessageModel.hpp"
#include "model/conference/ConferenceInfoModel.hpp"
#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"

#include "tool/Utils.hpp"

// =============================================================================

DEFINE_ABSTRACT_OBJECT(ChatMessageContentModel)

ChatMessageContentModel::ChatMessageContentModel(std::shared_ptr<linphone::Content> content,
                                                 std::shared_ptr<ChatMessageModel> chatMessageModel) {
	mChatMessageModel = chatMessageModel;
	mContent = content;
	assert(content);
	if (content->isFile() || content->isFileEncrypted() || content->isFileTransfer()) {
		createThumbnail();
	}
	if (mChatMessageModel)
		connect(mChatMessageModel.get(), &ChatMessageModel::msgStateChanged, this,
		        [this] { emit messageStateChanged(mChatMessageModel->getState()); });
}

ChatMessageContentModel::~ChatMessageContentModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

// Create a thumbnail from the first content that have a file
void ChatMessageContentModel::createThumbnail() {
	auto path = Utils::coreStringToAppString(mContent->getFilePath());
	if (!path.isEmpty()) {
		auto isVideo = Utils::isVideo(path);
		emit wasDownloadedChanged(mContent, QFileInfo(path).isFile());
		emit thumbnailChanged(QStringLiteral("image://%1/%2").arg(ThumbnailProvider::ProviderId).arg(path));
		emit filePathChanged(mContent, path);
	}
}

void ChatMessageContentModel::removeDownloadedFile(QString filePath) {
	if (!filePath.isEmpty()) {
		QFile(filePath).remove();
	}
}

void ChatMessageContentModel::downloadFile(const QString &name) {
	if (!mChatMessageModel) return;
	switch (mChatMessageModel->getState()) {
		case linphone::ChatMessage::State::Delivered:
		case linphone::ChatMessage::State::DeliveredToUser:
		case linphone::ChatMessage::State::Displayed:
		case linphone::ChatMessage::State::FileTransferDone:
			break;
		case linphone::ChatMessage::State::FileTransferInProgress:
			return;
		default:
			qWarning() << QStringLiteral("Wrong message state when requesting downloading, state=.")
			           << LinphoneEnums::fromLinphone(mChatMessageModel->getState());
	}
	bool soFarSoGood;
	const QString safeFilePath = Utils::getSafeFilePath(
	    QStringLiteral("%1%2").arg(App::getInstance()->getSettings()->getDownloadFolder()).arg(name), &soFarSoGood);

	if (!soFarSoGood) {
		qWarning() << QStringLiteral("Unable to create safe file path for: %1.").arg(name);
		return;
	}
	mContent->setFilePath(Utils::appStringToCoreString(safeFilePath));

	if (!mContent->isFileTransfer()) {
		Utils::showInformationPopup(
		    //: Error
		    tr("popup_error_title"),
		    //: This file was already downloaded and is no more on the server. Your peer have to resend it if you want
		    //: to get it
		    tr("popup_download_error_message"), false);
	} else {
		if (!mChatMessageModel->getMonitor()->downloadContent(mContent))
			qWarning() << QStringLiteral("Unable to download file of entry %1.").arg(name);
	}
}

void ChatMessageContentModel::cancelDownloadFile() {
	if (mChatMessageModel && mChatMessageModel->getMonitor()) {
		mChatMessageModel->getMonitor()->cancelFileTransfer();
	}
}

void ChatMessageContentModel::openFile(const QString &name, bool wasDownloaded, bool showDirectory) {
	if (mChatMessageModel &&
	    ((!wasDownloaded && !mChatMessageModel->getMonitor()->isOutgoing()) || mContent->getFilePath() == "")) {
		downloadFile(name);
	} else {
		QFileInfo info(Utils::coreStringToAppString(mContent->getFilePath()));
		showDirectory = showDirectory || !info.exists();
		if (!QDesktopServices::openUrl(QUrl(
		        QStringLiteral("file:///%1").arg(showDirectory ? info.absolutePath() : info.absoluteFilePath()))) &&
		    !showDirectory) {
			QDesktopServices::openUrl(QUrl(QStringLiteral("file:///%1").arg(info.absolutePath())));
		}
	}
}

bool ChatMessageContentModel::saveAs(const QString &path) {
	QString cachePath = Utils::coreStringToAppString(mContent->exportPlainFile());
	bool toDelete = true;
	bool result = false;
	if (cachePath.isEmpty()) {
		cachePath = Utils::coreStringToAppString(mContent->getFilePath());
		toDelete = false;
	}
	if (!cachePath.isEmpty()) {
		QString decodedPath = QUrl::fromPercentEncoding(path.toUtf8());
		QFile file(cachePath);
		QFile newFile(decodedPath);
		if (newFile.exists()) newFile.remove();
		result = file.copy(decodedPath);
		if (toDelete) file.remove();
		if (result) QDesktopServices::openUrl(QUrl(QStringLiteral("file:///%1").arg(decodedPath)));
	}

	emit fileSavedChanged(result);
	return result;
}

const std::shared_ptr<linphone::Content> &ChatMessageContentModel::getContent() const {
	return mContent;
}
