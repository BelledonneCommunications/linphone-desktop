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

#include "AccountModel.hpp"

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"
#include "tool/providers/AvatarProvider.hpp"
#include <QDebug>
#include <QUrl>

DEFINE_ABSTRACT_OBJECT(AccountModel)

AccountModel::AccountModel(const std::shared_ptr<linphone::Account> &account, QObject *parent)
    : ::Listener<linphone::Account, linphone::AccountListener>(account, parent) {
	mustBeInLinphoneThread(getClassName());
	connect(CoreModel::getInstance().get(), &CoreModel::defaultAccountChanged, this,
	        &AccountModel::onDefaultAccountChanged);

	// Hack because Account doesn't provide callbacks on updated data
	connect(this, &AccountModel::defaultAccountChanged, this,
	        [this]() { emit pictureUriChanged(Utils::coreStringToAppString(mMonitor->getParams()->getPictureUri())); });

	connect(CoreModel::getInstance().get(), &CoreModel::unreadNotificationsChanged, this, [this]() {
		emit unreadNotificationsChanged(0 /*mMonitor->getUnreadChatMessageCount()*/,
		                                mMonitor->getMissedCallsCount()); // TODO
	});
}

AccountModel::~AccountModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void AccountModel::onRegistrationStateChanged(const std::shared_ptr<linphone::Account> &account,
                                              linphone::RegistrationState state,
                                              const std::string &message) {
	emit registrationStateChanged(account, state, message);
}

void AccountModel::setPictureUri(QString uri) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto account = std::dynamic_pointer_cast<linphone::Account>(mMonitor);
	auto params = account->getParams()->clone();
	auto oldPictureUri = Utils::coreStringToAppString(params->getPictureUri());
	if (!oldPictureUri.isEmpty()) {
		QString appPrefix = QStringLiteral("image://%1/").arg(AvatarProvider::ProviderId);
		if (oldPictureUri.startsWith(appPrefix)) {
			oldPictureUri = Paths::getAvatarsDirPath() + oldPictureUri.mid(appPrefix.length());
		}
		QFile oldPicture(oldPictureUri);
		if (!oldPicture.remove()) qWarning() << log().arg("Cannot delete old avatar file at " + oldPictureUri);
	}
	params->setPictureUri(Utils::appStringToCoreString(uri));
	account->setParams(params);
	// Hack because Account doesn't provide callbacks on updated data
	// emit pictureUriChanged(uri);
	emit CoreModel::getInstance()->defaultAccountChanged(CoreModel::getInstance()->getCore(),
	                                                     CoreModel::getInstance()->getCore()->getDefaultAccount());
}

void AccountModel::onDefaultAccountChanged() {
	emit defaultAccountChanged(CoreModel::getInstance()->getCore()->getDefaultAccount() == mMonitor);
}

void AccountModel::setDefault() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	core->setDefaultAccount(mMonitor);
}

void AccountModel::removeAccount() {
	CoreModel::getInstance()->getCore()->removeAccount(mMonitor);
}
