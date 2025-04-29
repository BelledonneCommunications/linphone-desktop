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

#include "ChatMessageModel.hpp"

#include <QDebug>

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(ChatMessageModel)

ChatMessageModel::ChatMessageModel(const std::shared_ptr<linphone::ChatMessage> &chatMessage, QObject *parent)
    : ::Listener<linphone::ChatMessage, linphone::ChatMessageListener>(chatMessage, parent) {
	// lDebug() << "[ChatMessageModel] new" << this << " / SDKModel=" << chatMessage.get();
	mustBeInLinphoneThread(getClassName());
}

ChatMessageModel::~ChatMessageModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

QString ChatMessageModel::getText() const {
	return ToolModel::getMessageFromContent(mMonitor->getContents());
}

QString ChatMessageModel::getPeerAddress() const {
	return Utils::coreStringToAppString(mMonitor->getPeerAddress()->asStringUriOnly());
}

QDateTime ChatMessageModel::getTimestamp() const {
	return QDateTime::fromSecsSinceEpoch(mMonitor->getTime());
}

std::shared_ptr<linphone::Buffer>
ChatMessageModel::onFileTransferSend(const std::shared_ptr<linphone::ChatMessage> &message,
                                     const std::shared_ptr<linphone::Content> &content,
                                     size_t offset,
                                     size_t size) {
	return nullptr;
}
