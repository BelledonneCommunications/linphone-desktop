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

#include <QQmlApplicationEngine>

#include "core/App.hpp"

#include "ParticipantCore.hpp"
// #include "ParticipantDeviceList.hpp"
#include "model/participant/ParticipantModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

// =============================================================================

DEFINE_ABSTRACT_OBJECT(ParticipantCore)

QSharedPointer<ParticipantCore> ParticipantCore::create(const std::shared_ptr<linphone::Participant> &participant) {
	auto sharedPointer = QSharedPointer<ParticipantCore>(new ParticipantCore(participant), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

ParticipantCore::ParticipantCore(const std::shared_ptr<linphone::Participant> &participant) : QObject(nullptr) {
	if (participant) mustBeInLinphoneThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mParticipantModel = Utils::makeQObject_ptr<ParticipantModel>(participant);
	mParticipantModel->moveToThread(CoreModel::getInstance()->thread());
	if (participant) {
		mAdminStatus = participant->isAdmin();
		mSipAddress = Utils::coreStringToAppString(participant->getAddress()->asStringUriOnly());
		mIsMe = ToolModel::isMe(mSipAddress);
		mCreationTime = QDateTime::fromSecsSinceEpoch(participant->getCreationTime());
		mDisplayName = Utils::coreStringToAppString(participant->getAddress()->getDisplayName());
		if (mDisplayName.isEmpty())
			mDisplayName = Utils::coreStringToAppString(participant->getAddress()->getUsername());
		for (auto &device : participant->getDevices()) {
			auto name = Utils::coreStringToAppString(device->getName());
			auto address = Utils::coreStringToAppString(device->getAddress()->asStringUriOnly());
			QVariantMap map;
			map.insert("name", name);
			map.insert("address", address);
			mParticipantDevices.append(map);
		}
	} else mIsMe = false;
}

ParticipantCore::~ParticipantCore() {
	mustBeInMainThread("~" + getClassName());
}

void ParticipantCore::setSelf(QSharedPointer<ParticipantCore> me) {
	mParticipantConnection = SafeConnection<ParticipantCore, ParticipantModel>::create(me, mParticipantModel);
	mParticipantConnection->makeConnectToCore(&ParticipantCore::lStartInvitation, [this](const int &secs) {
		QTimer::singleShot(secs * 1000, this, &ParticipantCore::onEndOfInvitation);
	});
	connect(this, &ParticipantCore::sipAddressChanged, this, &ParticipantCore::updateIsMe);
}

int ParticipantCore::getSecurityLevel() const {
	return mSecurityLevel;
}

int ParticipantCore::getDeviceCount() const {
	return mParticipantDevices.size();
}

bool ParticipantCore::isMe() const {
	return mIsMe;
}

void ParticipantCore::setIsMe(bool isMe) {
	if (mIsMe != isMe) {
		mIsMe = isMe;
		emit isMeChanged();
	}
}

void ParticipantCore::updateIsMe() {
	mParticipantConnection->invokeToModel([this, address = mSipAddress]() {
		mParticipantConnection->invokeToCore([this, isMe = ToolModel::isMe(address)]() { setIsMe(isMe); });
	});
}

QString ParticipantCore::getSipAddress() const {
	return mSipAddress;
}
void ParticipantCore::setSipAddress(const QString &address) {
	if (mSipAddress != address) {
		mSipAddress = address;
		emit sipAddressChanged();
	}
}

void ParticipantCore::setDisplayName(const QString &name) {
	if (mDisplayName != name) {
		mDisplayName = name;
		emit displayNameChanged();
	}
}

QString ParticipantCore::getDisplayName() const {
	return mDisplayName;
}

QDateTime ParticipantCore::getCreationTime() const {
	return mCreationTime;
}
void ParticipantCore::setCreationTime(const QDateTime &date) {
	if (date != mCreationTime) {
		mCreationTime = date;
		emit creationTimeChanged();
	}
}

bool ParticipantCore::isAdmin() const {
	return mAdminStatus;
}

bool ParticipantCore::isFocus() const {
	return mIsFocus;
}

void ParticipantCore::setIsAdmin(const bool &status) {
	if (status != mAdminStatus) {
		mAdminStatus = status;
		emit isAdminChanged();
	}
}

void ParticipantCore::setIsFocus(const bool &focus) {
	if (focus != mIsFocus) {
		mIsFocus = focus;
		emit isFocusChanged();
	}
}

void ParticipantCore::setSecurityLevel(int level) {
	if (level != mSecurityLevel) {
		mSecurityLevel = level;
		emit securityLevelChanged();
	}
}

void ParticipantCore::onSecurityLevelChanged() {
	emit securityLevelChanged();
}
void ParticipantCore::onDeviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device) {
	emit deviceSecurityLevelChanged(device);
}

QList<QVariant> ParticipantCore::getParticipantDevices() {
	return mParticipantDevices;
}

void ParticipantCore::onEndOfInvitation() {
	emit invitationTimeout(this);
}
