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

#include "ChatMessageContentList.hpp"
#include "core/App.hpp"
#include "core/chat/ChatCore.hpp"
#include "core/chat/message/content/ChatMessageContentGui.hpp"

#include <QMimeDatabase>
#include <QSharedPointer>

#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(ChatMessageContentList)

QSharedPointer<ChatMessageContentList> ChatMessageContentList::create() {
	auto model = QSharedPointer<ChatMessageContentList>(new ChatMessageContentList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

ChatMessageContentList::ChatMessageContentList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ChatMessageContentList::~ChatMessageContentList() {
	mustBeInMainThread("~" + getClassName());
	mModelConnection = nullptr;
}

ChatMessageGui *ChatMessageContentList::getChatMessage() const {
	if (mChatMessageCore) return new ChatMessageGui(mChatMessageCore);
	else return nullptr;
}

QSharedPointer<ChatMessageCore> ChatMessageContentList::getChatMessageCore() const {
	return mChatMessageCore;
}

void ChatMessageContentList::setChatMessageCore(QSharedPointer<ChatMessageCore> core) {
	if (mChatMessageCore != core) {
		// if (mChatMessageCore) disconnect(mChatMessageCore.get(), &ChatCore::, this, nullptr);
		mChatMessageCore = core;
		// if (mChatMessageCore)
		// connect(mChatMessageCore.get(), &ChatCore::messageListChanged, this, &ChatMessageContentList::lUpdate);
		emit chatMessageChanged();
		lUpdate();
	}
}

void ChatMessageContentList::setChatMessageGui(ChatMessageGui *chat) {
	auto chatCore = chat ? chat->mCore : nullptr;
	setChatMessageCore(chatCore);
}

int ChatMessageContentList::findFirstUnreadIndex() {
	auto chatList = getSharedList<ChatMessageCore>();
	auto it = std::find_if(chatList.begin(), chatList.end(),
	                       [](const QSharedPointer<ChatMessageCore> item) { return !item->isRead(); });
	return it == chatList.end() ? -1 : std::distance(chatList.begin(), it);
}

void ChatMessageContentList::addFiles(const QStringList &paths) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));

	QStringList finalList;
	QList<QFileInfo> fileList;

	int nbNotFound = 0;
	QString lastNotFound;
	int nbExcess = 0;
	int count = rowCount();

	for (auto &path : paths) {
		QFileInfo file(path.toUtf8());
		// #ifdef _WIN32
		// 	// A bug from FileDialog suppose that the file is local and overwrite the uri by removing "\\".
		// 	if (!file.exists()) {
		// 		path.prepend("\\\\");
		// 		file.setFileName(path);
		// 	}
		// #endif
		if (!file.exists()) {
			++nbNotFound;
			lastNotFound = path;
			continue;
		}

		if (count + finalList.count() >= 12) {
			++nbExcess;
			continue;
		}
		finalList.append(path);
		fileList.append(file);
	}
	if (nbNotFound > 0) {
		//: Error adding file
		Utils::showInformationPopup(tr("popup_error_title"),
		                            //: File was not found: %1
		                            (nbNotFound == 1 ? tr("popup_error_path_does_not_exist_message").arg(lastNotFound)
		                                             //: %n files were not found
		                                             : tr("popup_error_nb_files_not_found_message").arg(nbNotFound)),
		                            false);
	}
	if (nbExcess > 0) {
		//: Error
		Utils::showInformationPopup(tr("popup_error_title"),
		                            //: You can send 12 files maximum at a time. %n files were ignored
		                            tr("popup_error_max_files_count_message", "", nbExcess), false);
	}

	mModelConnection->invokeToModel([this, finalList, fileList] {
		int nbTooBig = 0;
		int nbMimeError = 0;
		QString lastMimeError;
		QList<QSharedPointer<ChatMessageContentCore>> contentList;
		for (auto &file : fileList) {
			qint64 fileSize = file.size();
			if (fileSize > Constants::FileSizeLimit) {
				++nbTooBig;
				lWarning() << log().arg("Unable to send file. (Size limit=%1)").arg(Constants::FileSizeLimit);
				continue;
			}
			auto name = file.fileName().toStdString();
			auto path = file.filePath();
			std::shared_ptr<linphone::Content> content = CoreModel::getInstance()->getCore()->createContent();
			QStringList mimeType = QMimeDatabase().mimeTypeForFile(path).name().split('/');
			if (mimeType.length() != 2) {
				++nbMimeError;
				lastMimeError = path;
				lWarning() << log().arg("Unable to get supported mime type for: `%1`.").arg(path);
				continue;
			}
			content->setType(Utils::appStringToCoreString(mimeType[0]));
			content->setSubtype(Utils::appStringToCoreString(mimeType[1]));
			content->setSize(size_t(fileSize));
			content->setName(name);
			content->setFilePath(Utils::appStringToCoreString(path));
			contentList.append(ChatMessageContentCore::create(content, nullptr));
		}
		if (nbTooBig > 0) {
			//: Error adding file
			Utils::showInformationPopup(
			    tr("popup_error_title"),
			    //: %n files were ignored cause they exceed the maximum size. (Size limit=%2)
			    tr("popup_error_file_too_big_message").arg(nbTooBig).arg(Constants::FileSizeLimit), false);
		}
		if (nbMimeError > 0) {
			//: Error adding file
			Utils::showInformationPopup(tr("popup_error_title"),
			                            //: Unable to get supported mime type for: `%1`.
			                            (nbMimeError == 1
			                                 ? tr("popup_error_unsupported_file_message").arg(lastMimeError)
			                                 //: Unable to get supported mime type for %1 files.
			                                 : tr("popup_error_unsupported_files_message").arg(nbMimeError)),
			                            false);
		}

		mModelConnection->invokeToCore([this, contentList] {
			for (auto &contentCore : contentList) {
				connect(contentCore.get(), &ChatMessageContentCore::isFileChanged, this, [this, contentCore] {
					int i = -1;
					get(contentCore.get(), &i);
					emit dataChanged(index(i), index(i));
				});
				add(contentCore);
				contentCore->lCreateThumbnail(
				    true); // Was not created because linphone::Content is not considered as a file (yet)
			}
		});
	});
}

void ChatMessageContentList::setSelf(QSharedPointer<ChatMessageContentList> me) {
	mModelConnection = SafeConnection<ChatMessageContentList, CoreModel>::create(me, CoreModel::getInstance());

	mModelConnection->makeConnectToCore(&ChatMessageContentList::lUpdate, [this]() {
		for (auto &content : getSharedList<ChatMessageContentCore>()) {
			if (content) disconnect(content.get(), &ChatMessageContentCore::wasDownloadedChanged, this, nullptr);
			if (content) disconnect(content.get(), &ChatMessageContentCore::thumbnailChanged, this, nullptr);
		}
		if (!mChatMessageCore) return;
		auto contents = mChatMessageCore->getChatMessageContentList();
		for (auto &content : contents) {
			connect(content.get(), &ChatMessageContentCore::wasDownloadedChanged, this,
			        [this, content](bool wasDownloaded) {
				        if (wasDownloaded) {
					        content->lCreateThumbnail();
				        }
			        });
			connect(content.get(), &ChatMessageContentCore::thumbnailChanged, this, [this] { emit lUpdate(); });
		}
		resetData<ChatMessageContentCore>(contents);
	});
	mModelConnection->makeConnectToCore(&ChatMessageContentList::lAddFiles,
	                                    [this](const QStringList &paths) { addFiles(paths); });
	emit lUpdate();
}

QVariant ChatMessageContentList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(new ChatMessageContentGui(mList[row].objectCast<ChatMessageContentCore>()));
	return QVariant();
}