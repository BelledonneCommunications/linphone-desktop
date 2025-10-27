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

#include "ChatMessageContentCore.hpp"
#include "core/App.hpp"
#include "core/chat/ChatCore.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/providers/ThumbnailProvider.hpp"

DEFINE_ABSTRACT_OBJECT(ChatMessageContentCore)

QSharedPointer<ChatMessageContentCore>
ChatMessageContentCore::create(const std::shared_ptr<linphone::Content> &content,
                               std::shared_ptr<ChatMessageModel> chatMessageModel) {
	auto sharedPointer = QSharedPointer<ChatMessageContentCore>(new ChatMessageContentCore(content, chatMessageModel),
	                                                            &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

ChatMessageContentCore::ChatMessageContentCore(const std::shared_ptr<linphone::Content> &content,
                                               std::shared_ptr<ChatMessageModel> chatMessageModel) {
	if (content) {
		mName = Utils::coreStringToAppString(content->getName());
		if (mName.isEmpty()) { // Try to find the name from file Path
			QString fileName = Utils::coreStringToAppString(content->getFilePath());
			if (!fileName.isEmpty()) {
				mName = QFileInfo(fileName).baseName();
			}
		}
		mFilePath = Utils::coreStringToAppString(content->getFilePath());
		mIsFile = content->isFile();
		mIsFileEncrypted = content->isFileEncrypted();
		mIsFileTransfer = content->isFileTransfer();
		mIsCalendar = content->isIcalendar();
		if (content->isIcalendar()) {
			auto conferenceInfo = linphone::Factory::get()->createConferenceInfoFromIcalendarContent(content);
			mConferenceInfo = ConferenceInfoCore::create(conferenceInfo);
		}
		mIsMultipart = content->isMultipart();
		mIsText = content->isText();
		mIsVoiceRecording = content->isVoiceRecording();
		mIsVideo = Utils::isVideo(mFilePath);
		mFileSize = (quint64)content->getFileSize();
		mFileDuration = content->getFileDuration();
		mFileOffset = 0;
		mUtf8Text = Utils::coreStringToAppString(content->getUtf8Text());
		auto chatRoom = chatMessageModel ? chatMessageModel->getMonitor()->getChatRoom() : nullptr;
		mRichFormatText = ToolModel::encodeTextToQmlRichFormat(mUtf8Text, {}, chatRoom);
		mWasDownloaded = !mFilePath.isEmpty() && QFileInfo(mFilePath).isFile();
		mThumbnail = mFilePath.isEmpty()
		                 ? QString()
		                 : QStringLiteral("image://%1/%2").arg(ThumbnailProvider::ProviderId).arg(mFilePath);
		mChatMessageContentModel = Utils::makeQObject_ptr<ChatMessageContentModel>(content, chatMessageModel);
	}
}

ChatMessageContentCore ::~ChatMessageContentCore() {
}

void ChatMessageContentCore::setSelf(QSharedPointer<ChatMessageContentCore> me) {
	mChatMessageContentModelConnection =
	    SafeConnection<ChatMessageContentCore, ChatMessageContentModel>::create(me, mChatMessageContentModel);

	auto updateThumbnailType = [this] {
		if (Utils::isVideo(mFilePath)) mIsVideo = true;
		emit isVideoChanged();
	};

	mChatMessageContentModelConnection->makeConnectToCore(
	    &ChatMessageContentCore::lCreateThumbnail, [this](const bool &force = false) {
		    mChatMessageContentModelConnection->invokeToModel(
		        [this, force] { mChatMessageContentModel->createThumbnail(); });
	    });
	mChatMessageContentModelConnection->makeConnectToModel(
	    &ChatMessageContentModel::thumbnailChanged, [this, updateThumbnailType](QString thumbnail) {
		    mChatMessageContentModelConnection->invokeToCore([this, thumbnail] { setThumbnail(thumbnail); });
	    });

	mChatMessageContentModelConnection->makeConnectToCore(&ChatMessageContentCore::lDownloadFile, [this]() {
		mChatMessageContentModelConnection->invokeToModel([this] {
			QString error;
			bool downloaded = mChatMessageContentModel->downloadFile(mName, &error);
			if (!downloaded) {
				mChatMessageContentModelConnection->invokeToCore([this, &error] {
					QString message = error;
					//: Error downloading file %1
					if (error.isEmpty()) error = tr("download_file_default_error").arg(mName);
					Utils::showInformationPopup(tr("info_popup_error_titile"), message, false);
				});
			}
		});
	});
	mChatMessageContentModelConnection->makeConnectToModel(
	    &ChatMessageContentModel::wasDownloadedChanged,
	    [this](const std::shared_ptr<linphone::Content> &content, bool downloaded) {
		    mChatMessageContentModelConnection->invokeToCore([this, downloaded] { setWasDownloaded(downloaded); });
	    });
	mChatMessageContentModelConnection->makeConnectToModel(
	    &ChatMessageContentModel::filePathChanged,
	    [this](const std::shared_ptr<linphone::Content> &content, QString filePath) {
		    auto isFile = content->isFile();
		    auto isFileTransfer = content->isFileTransfer();
		    auto isFileEncrypted = content->isFileEncrypted();
		    mChatMessageContentModelConnection->invokeToCore([this, filePath, isFile, isFileTransfer, isFileEncrypted] {
			    setIsFile(isFile || QFileInfo(filePath).isFile());
			    setIsFileTransfer(isFileTransfer);
			    setIsFileEncrypted(isFileEncrypted);
			    setFilePath(filePath);
		    });
	    });

	mChatMessageContentModelConnection->makeConnectToCore(&ChatMessageContentCore::lCancelDownloadFile, [this]() {
		mChatMessageContentModelConnection->invokeToModel([this] { mChatMessageContentModel->cancelDownloadFile(); });
	});
	mChatMessageContentModelConnection->makeConnectToCore(
	    &ChatMessageContentCore::lOpenFile, [this](bool showDirectory = false) {
		    if (!QFileInfo(mFilePath).exists()) {
			    //: Error
			    Utils::showInformationPopup(tr("popup_error_title"),
			                                //: Could not open file : unknown path %1
			                                tr("popup_open_file_error_does_not_exist_message").arg(mFilePath), false);
		    } else {
			    mChatMessageContentModelConnection->invokeToModel([this, showDirectory] {
				    mChatMessageContentModel->openFile(mName, mWasDownloaded, showDirectory);
			    });
		    }
	    });
	mChatMessageContentModelConnection->makeConnectToModel(
	    &ChatMessageContentModel::messageStateChanged, [this](linphone::ChatMessage::State state) {
		    mChatMessageContentModelConnection->invokeToCore(
		        [this, msgState = LinphoneEnums::fromLinphone(state)] { emit msgStateChanged(msgState); });
	    });
}

bool ChatMessageContentCore::isFile() const {
	return mIsFile;
}

void ChatMessageContentCore::setIsFile(bool isFile) {
	if (mIsFile != isFile) {
		mIsFile = isFile;
		emit isFileChanged();
	}
}

bool ChatMessageContentCore::isVideo() const {
	return mIsVideo;
}

bool ChatMessageContentCore::isFileEncrypted() const {
	return mIsFileEncrypted;
}

void ChatMessageContentCore::setIsFileEncrypted(bool isFileEncrypted) {
	if (mIsFileEncrypted != isFileEncrypted) {
		mIsFileEncrypted = isFileEncrypted;
		emit isFileEncryptedChanged();
	}
}

bool ChatMessageContentCore::isFileTransfer() const {
	return mIsFileTransfer;
}

void ChatMessageContentCore::setIsFileTransfer(bool isFileTransfer) {
	if (mIsFileTransfer != isFileTransfer) {
		mIsFileTransfer = isFileTransfer;
		emit isFileTransferChanged();
	}
}

bool ChatMessageContentCore::isCalendar() const {
	return mIsCalendar;
}

bool ChatMessageContentCore::isMultipart() const {
	return mIsMultipart;
}

bool ChatMessageContentCore::isText() const {
	return mIsText;
}

bool ChatMessageContentCore::isVoiceRecording() const {
	return mIsVoiceRecording;
}

QString ChatMessageContentCore::getFilePath() const {
	return mFilePath;
}

void ChatMessageContentCore::setFilePath(QString path) {
	if (mFilePath != path) {
		mFilePath = path;
		emit filePathChanged();
	}
}

QString ChatMessageContentCore::getUtf8Text() const {
	return mUtf8Text;
}

QString ChatMessageContentCore::getName() const {
	return mName;
}

quint64 ChatMessageContentCore::getFileSize() const {
	return mFileSize;
}

quint64 ChatMessageContentCore::getFileOffset() const {
	return mFileOffset;
}

void ChatMessageContentCore::setFileOffset(quint64 fileOffset) {
	if (mFileOffset != fileOffset) {
		mFileOffset = fileOffset;
		emit fileOffsetChanged();
	}
}

int ChatMessageContentCore::getFileDuration() const {
	return mFileDuration;
}

ConferenceInfoGui *ChatMessageContentCore::getConferenceInfoGui() const {
	return mConferenceInfo ? new ConferenceInfoGui(mConferenceInfo) : nullptr;
}

bool ChatMessageContentCore::wasDownloaded() const {
	return mWasDownloaded;
}

QString ChatMessageContentCore::getThumbnail() const {
	return mThumbnail;
}

void ChatMessageContentCore::setThumbnail(const QString &data) {
	if (mThumbnail != data) {
		mThumbnail = data;
		emit thumbnailChanged();
	}
}
void ChatMessageContentCore::setWasDownloaded(bool wasDownloaded) {
	if (mWasDownloaded != wasDownloaded) {
		mWasDownloaded = wasDownloaded;
		emit wasDownloadedChanged(wasDownloaded);
	}
}

const std::shared_ptr<ChatMessageContentModel> &ChatMessageContentCore::getContentModel() const {
	return mChatMessageContentModel;
}
