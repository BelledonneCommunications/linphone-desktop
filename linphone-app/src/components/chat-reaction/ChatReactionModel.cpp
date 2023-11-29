/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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

#include "ChatReactionModel.hpp"

#include "app/App.hpp"
#include "utils/Utils.hpp"

#include <QQmlApplicationEngine>

ChatReactionModel::ChatReactionModel(const std::shared_ptr<const linphone::ChatMessageReaction>& reaction) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mBody = Utils::coreStringToAppString(reaction->getBody());
	auto fromAddress = reaction->getFromAddress()->clone();
	fromAddress->clean();
	mFromAddress = Utils::coreStringToAppString(fromAddress->asStringUriOnly());
}

QString ChatReactionModel::getBody() const {
	return mBody;
}

void ChatReactionModel::setBody(const QString& body) {
	mBody = body;
	emit bodyChanged();
}
	
QString ChatReactionModel::getFromAddress() const {
	return mFromAddress;
}
