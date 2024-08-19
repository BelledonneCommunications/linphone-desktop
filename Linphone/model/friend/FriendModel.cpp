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

#include "FriendModel.hpp"

#include "core/path/Paths.hpp"
#include "tool/Utils.hpp"
#include "tool/providers/AvatarProvider.hpp"
#include <QDebug>
#include <QUrl>

DEFINE_ABSTRACT_OBJECT(FriendModel)

FriendModel::FriendModel(const std::shared_ptr<linphone::Friend> &contact, const QString &name, QObject *parent)
    : ::Listener<linphone::Friend, linphone::FriendListener>(contact, parent) {
	mustBeInLinphoneThread(getClassName());
	connect(this, &FriendModel::addressesChanged, [this] {
		if (mMonitor->getAddresses().size() == 0) return;
		if (!mMonitor->getAddress()) mMonitor->setAddress(*mMonitor->getAddresses().begin());
	});
	connect(this, &FriendModel::defaultAddressChanged, [this] {
		if (mMonitor->getAddresses().size() == 0) return;
		if (!mMonitor->getAddress()) mMonitor->setAddress(*mMonitor->getAddresses().begin());
	});
	if (!contact->getName().empty() || !name.isEmpty())
		mMonitor->setName(contact->getName().empty() ? Utils::appStringToCoreString(name) : contact->getName());
};

FriendModel::~FriendModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

std::shared_ptr<linphone::Friend> FriendModel::getFriend() const {
	return mMonitor;
}

QDateTime FriendModel::getPresenceTimestamp() const {
	if (mMonitor->getPresenceModel()) {
		time_t timestamp = mMonitor->getPresenceModel()->getLatestActivityTimestamp();
		if (timestamp == -1) return QDateTime();
		else return QDateTime::fromMSecsSinceEpoch(timestamp * 1000);
	} else return QDateTime();
}

void FriendModel::setAddress(const std::shared_ptr<linphone::Address> &address) {
	if (address) {
		mMonitor->setAddress(address);
		emit defaultAddressChanged();
	}
}

std::list<std::shared_ptr<linphone::FriendPhoneNumber>> FriendModel::getPhoneNumbers() const {
	return mMonitor->getPhoneNumbersWithLabel();
}

void FriendModel::appendPhoneNumber(const std::shared_ptr<linphone::FriendPhoneNumber> &number) {
	if (number) {
		mMonitor->addPhoneNumberWithLabel(number);
		emit phoneNumbersChanged();
	}
}

void FriendModel::appendPhoneNumbers(const std::list<std::shared_ptr<linphone::FriendPhoneNumber>> &numbers) {
	for (auto &num : numbers)
		if (num) mMonitor->addPhoneNumberWithLabel(num);
	emit phoneNumbersChanged();
}

void FriendModel::resetPhoneNumbers(const std::list<std::shared_ptr<linphone::FriendPhoneNumber>> &numbers) {
	for (auto &num : mMonitor->getPhoneNumbers())
		mMonitor->removePhoneNumber(num);
	for (auto &num : numbers)
		if (num) mMonitor->addPhoneNumberWithLabel(num);
	emit phoneNumbersChanged();
}

void FriendModel::removePhoneNumber(const QString &number) {
	mMonitor->removePhoneNumber(Utils::appStringToCoreString(number));
	emit phoneNumbersChanged();
}

void FriendModel::clearPhoneNumbers() {
	for (auto &number : mMonitor->getPhoneNumbers())
		mMonitor->removePhoneNumber(number);
	emit phoneNumbersChanged();
}

std::list<std::shared_ptr<linphone::Address>> FriendModel::getAddresses() const {
	return mMonitor->getAddresses();
}

void FriendModel::appendAddress(const std::shared_ptr<linphone::Address> &addr) {
	if (addr) {
		mMonitor->addAddress(addr);
		emit addressesChanged();
	}
}

void FriendModel::appendAddresses(const std::list<std::shared_ptr<linphone::Address>> &addresses) {
	for (auto &addr : addresses)
		if (addr) mMonitor->addAddress(addr);
	emit addressesChanged();
}

void FriendModel::resetAddresses(const std::list<std::shared_ptr<linphone::Address>> &addresses) {
	for (auto &addr : mMonitor->getAddresses())
		mMonitor->removeAddress(addr);
	for (auto &addr : addresses)
		if (addr) mMonitor->addAddress(addr);
	emit addressesChanged();
}

void FriendModel::removeAddress(const std::shared_ptr<linphone::Address> &addr) {
	if (addr) {
		mMonitor->removeAddress(addr);
		emit addressesChanged();
	}
}

void FriendModel::clearAddresses() {
	for (auto &addr : mMonitor->getAddresses())
		if (addr) mMonitor->removeAddress(addr);
	emit addressesChanged();
}

QString FriendModel::getName() const {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(mMonitor->getName());
	}
	if (mMonitor->getVcard()) return Utils::coreStringToAppString(mMonitor->getName());
	else return QString();
}

void FriendModel::setName(const QString &name) {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(Utils::appStringToCoreString(name));
	}
	if (mMonitor->getVcard()) mMonitor->setName(Utils::appStringToCoreString(name));
}

QString FriendModel::getGivenName() const {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(mMonitor->getName());
	}
	if (mMonitor->getVcard()) return Utils::coreStringToAppString(mMonitor->getVcard()->getGivenName());
	else return QString();
}

void FriendModel::setGivenName(const QString &name) {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(mMonitor->getName());
	}
	if (mMonitor->getVcard()) {
		mMonitor->getVcard()->setGivenName(Utils::appStringToCoreString(name));
		emit givenNameChanged(name);
	}
}

QString FriendModel::getFamilyName() const {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(mMonitor->getName());
	}
	if (mMonitor->getVcard()) return Utils::coreStringToAppString(mMonitor->getVcard()->getFamilyName());
	else return QString();
}

void FriendModel::setFamilyName(const QString &name) {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(mMonitor->getName());
	}
	if (mMonitor->getVcard()) {
		mMonitor->getVcard()->setFamilyName(Utils::appStringToCoreString(name));
		emit familyNameChanged(name);
	}
}

QString FriendModel::getOrganization() const {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(mMonitor->getName());
	}
	if (mMonitor->getVcard()) return Utils::coreStringToAppString(mMonitor->getVcard()->getOrganization());
	else return QString();
}

void FriendModel::setOrganization(const QString &orga) {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(mMonitor->getName());
	}
	if (mMonitor->getVcard()) {
		mMonitor->getVcard()->setOrganization(Utils::appStringToCoreString(orga));
		emit organizationChanged(orga);
	}
}

QString FriendModel::getJob() const {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(mMonitor->getName());
	}
	if (mMonitor->getVcard()) return Utils::coreStringToAppString(mMonitor->getVcard()->getJobTitle());
	else return QString();
}

void FriendModel::setJob(const QString &job) {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(mMonitor->getName());
	}
	if (mMonitor->getVcard()) {
		mMonitor->getVcard()->setJobTitle(Utils::appStringToCoreString(job));
		emit jobChanged(job);
	}
}

bool FriendModel::getStarred() const {
	return mMonitor->getStarred();
}

void FriendModel::setStarred(bool starred) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setStarred(starred);
	emit starredChanged(starred);
}
void FriendModel::onPresenceReceived(const std::shared_ptr<linphone::Friend> &contact) {
	emit presenceReceived(LinphoneEnums::fromLinphone(contact->getConsolidatedPresence()), getPresenceTimestamp());
}

QString FriendModel::getPictureUri() const {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(mMonitor->getName());
	}
	if (mMonitor->getVcard()) return Utils::coreStringToAppString(mMonitor->getVcard()->getPhoto());
	else return QString();
}

QString FriendModel::getVCardAsString() const {
	auto vcard = mMonitor->getVcard();
	bool created = false;
	if (!vcard) {
		created = mMonitor->createVcard(mMonitor->getName());
	}
	assert(mMonitor->getVcard());
	return Utils::coreStringToAppString(mMonitor->getVcard()->asVcard4String());
}

std::list<std::shared_ptr<linphone::FriendDevice>> FriendModel::getDevices() const {
	return mMonitor->getDevices();
}

linphone::SecurityLevel FriendModel::getSecurityLevel() const {
	return mMonitor->getSecurityLevel();
}

linphone::SecurityLevel
FriendModel::getSecurityLevelForAddress(const std::shared_ptr<linphone::Address> address) const {
	return mMonitor->getSecurityLevelForAddress(address);
}

void FriendModel::setPictureUri(const QString &uri) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto oldPictureUri = Utils::coreStringToAppString(mMonitor->getPhoto());
	if (!oldPictureUri.isEmpty()) {
		QString appPrefix = QStringLiteral("image://%1/").arg(AvatarProvider::ProviderId);
		if (oldPictureUri.startsWith(appPrefix)) {
			oldPictureUri = Paths::getAvatarsDirPath() + oldPictureUri.mid(appPrefix.length());
		}
		QFile oldPicture(oldPictureUri);
		if (!oldPicture.remove()) qWarning() << log().arg("Cannot delete old avatar file at " + oldPictureUri);
	}
	mMonitor->setPhoto(Utils::appStringToCoreString(uri));
	emit pictureUriChanged(uri);
}
