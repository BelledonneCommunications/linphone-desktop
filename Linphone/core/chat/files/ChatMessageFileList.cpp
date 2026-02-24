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

#include "ChatMessageFileList.hpp"
#include "core/App.hpp"
#include "core/chat/message/content/ChatMessageContentCore.hpp"

#include <QSharedPointer>

#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(ChatMessageFileList)

QSharedPointer<ChatMessageFileList> ChatMessageFileList::create() {
	auto model = QSharedPointer<ChatMessageFileList>(new ChatMessageFileList(), &QObject::deleteLater);
	model->setSelf(model);
	model->moveToThread(App::getInstance()->thread());
	return model;
}

ChatMessageFileList::ChatMessageFileList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ChatMessageFileList::~ChatMessageFileList() {
	mustBeInMainThread("~" + getClassName());
	mList.clear();
}

void ChatMessageFileList::setSelf(QSharedPointer<ChatMessageFileList> me) {
	mCoreModelConnection = SafeConnection<ChatMessageFileList, CoreModel>::create(me, CoreModel::getInstance());
	mCoreModelConnection->makeConnectToCore(&ChatMessageFileList::lUpdate, [this]() {
		mustBeInMainThread(log().arg(Q_FUNC_INFO));

		if (!mChat) {
			beginResetModel();
			mList.clear();
			endResetModel();
			return;
		}
		auto chatModel = mChat->getModel();
		if (!chatModel) {
			beginResetModel();
			mList.clear();
			endResetModel();
			return;
		}
		mCoreModelConnection->invokeToModel([this, chatModel]() {
			mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
			std::list<std::shared_ptr<linphone::Content>> medias;
			std::list<std::shared_ptr<linphone::Content>> docs;
			QList<QSharedPointer<ChatMessageContentCore>> *contents =
			    new QList<QSharedPointer<ChatMessageContentCore>>();
			if (mFilterType == (int)FilterContentType::Medias) {
				medias = chatModel->getSharedMedias();
			} else if (mFilterType == (int)FilterContentType::Documents) {
				docs = chatModel->getSharedDocuments();
			} else {
				medias = chatModel->getSharedMedias();
				docs = chatModel->getSharedDocuments();
			}
			for (auto it : medias) {
				if (it->isVoiceRecording()) continue;
				auto model = ChatMessageContentCore::create(it, nullptr);
				contents->push_back(model);
			}
			for (auto it : docs) {
				if (it->isVoiceRecording()) continue;
				auto model = ChatMessageContentCore::create(it, nullptr);
				contents->push_back(model);
			}
			mCoreModelConnection->invokeToCore([this, contents] {
				beginResetModel();
				mList.clear();
				for (auto i : *contents)
					mList << i.template objectCast<QObject>();
				endResetModel();
				delete contents;
			});
		});
	});
}

QSharedPointer<ChatCore> ChatMessageFileList::getChatCore() const {
	return mChat;
}

void ChatMessageFileList::setChatCore(QSharedPointer<ChatCore> chatCore) {
	if (mChat != chatCore) {
		// if (mChat) disconnect(mChat.get());
		mChat = chatCore;
		// if (mChat) connect(mChat.get(), &ChatCore::fileListChanged, this, lUpdate);
		lUpdate();
		emit chatChanged();
	}
}

int ChatMessageFileList::getFilterType() const {
	return mFilterType;
}

void ChatMessageFileList::setFilterType(int filterType) {
	if (mFilterType != filterType) {
		mFilterType = filterType;
		lUpdate();
	}
}

QVariant ChatMessageFileList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole)
		return QVariant::fromValue(new ChatMessageContentGui(mList[row].objectCast<ChatMessageContentCore>()));
	return QVariant();
}