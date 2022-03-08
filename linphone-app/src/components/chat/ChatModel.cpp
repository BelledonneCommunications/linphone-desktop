/*
 * Copyright (c) 2022 Belledonne Communications SARL.
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

#include "ChatModel.hpp"

#include <QQmlApplicationEngine>
#include <QDesktopServices>
#include <QImageReader>
#include <QMessageBox>

#include "app/App.hpp"
#include "app/paths/Paths.hpp"
#include "app/providers/ThumbnailProvider.hpp"

#include "components/chat-events/ChatMessageModel.hpp"

#include "utils/QExifImageHeader.hpp"
#include "utils/Utils.hpp"
#include "utils/Constants.hpp"
#include "components/Components.hpp"

// =============================================================================

ChatModel::ChatModel(QObject * parent ) : QObject(parent){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mContents = std::make_shared<ContentListModel>(nullptr);
}

std::shared_ptr<ContentListModel> ChatModel::getContentListModel() const {
	return mContents;
}

void ChatModel::clear() {
	mContents->clear();
}