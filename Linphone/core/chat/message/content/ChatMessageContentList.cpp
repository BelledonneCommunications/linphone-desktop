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

void ChatMessageContentList::setSelf(QSharedPointer<ChatMessageContentList> me) {
	mModelConnection = SafeConnection<ChatMessageContentList, CoreModel>::create(me, CoreModel::getInstance());

	mModelConnection->makeConnectToCore(&ChatMessageContentList::lUpdate, [this]() {
		for (auto &content : getSharedList<ChatMessageContentCore>()) {
			if (content) disconnect(content.get());
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
	mModelConnection->makeConnectToCore(&ChatMessageContentList::lAddFile, [this](const QString &path) {
		QFile file(path);
		// #ifdef _WIN32
		// 	// A bug from FileDialog suppose that the file is local and overwrite the uri by removing "\\".
		// 	if (!file.exists()) {
		// 		path.prepend("\\\\");
		// 		file.setFileName(path);
		// 	}
		// #endif
		if (!file.exists()) return;
		if (rowCount() >= 12) {
			//: Error
			Utils::showInformationPopup(tr("popup_error_title"),
			                            //: You can add 12 files maximum
			                            tr("popup_error_max_files_count_message"), false);
			return;
		}

		qint64 fileSize = file.size();
		if (fileSize > Constants::FileSizeLimit) {
			qWarning() << QStringLiteral("Unable to send file. (Size limit=%1)").arg(Constants::FileSizeLimit);
			return;
		}
		auto name = QFileInfo(file).fileName().toStdString();
		mModelConnection->invokeToModel([this, path, fileSize, name] {
			std::shared_ptr<linphone::Content> content = CoreModel::getInstance()->getCore()->createContent();
			{
				QStringList mimeType = QMimeDatabase().mimeTypeForFile(path).name().split('/');
				if (mimeType.length() != 2) {
					qWarning() << QStringLiteral("Unable to get supported mime type for: `%1`.").arg(path);
					return;
				}
				content->setType(Utils::appStringToCoreString(mimeType[0]));
				content->setSubtype(Utils::appStringToCoreString(mimeType[1]));
			}
			content->setSize(size_t(fileSize));
			content->setName(name);
			content->setFilePath(Utils::appStringToCoreString(path));
			auto contentCore = ChatMessageContentCore::create(content, nullptr);
			mModelConnection->invokeToCore([this, contentCore] {
				connect(contentCore.get(), &ChatMessageContentCore::isFileChanged, this, [this, contentCore] {
					int i = -1;
					get(contentCore.get(), &i);
					emit dataChanged(index(i), index(i));
				});
				add(contentCore);
				contentCore->lCreateThumbnail(
				    true); // Was not created because linphone::Content is not considered as a file (yet)
			});
		});
	});
	emit lUpdate();
}

QVariant ChatMessageContentList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(new ChatMessageContentGui(mList[row].objectCast<ChatMessageContentCore>()));
	return QVariant();
}