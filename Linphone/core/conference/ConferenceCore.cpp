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

#include "ConferenceCore.hpp"
#include "core/App.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

DEFINE_ABSTRACT_OBJECT(ConferenceCore)

QSharedPointer<ConferenceCore> ConferenceCore::create(const std::shared_ptr<linphone::Conference> &conference) {
	auto sharedPointer = QSharedPointer<ConferenceCore>(new ConferenceCore(conference), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}
ConferenceCore::ConferenceCore(const std::shared_ptr<linphone::Conference> &conference) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	// Should be call from model Thread
	mustBeInLinphoneThread(getClassName());
	mSubject = Utils::coreStringToAppString(conference->getSubject());
}
ConferenceCore::~ConferenceCore() {
	mustBeInMainThread("~" + getClassName());
	emit mConferenceModel->removeListener();
}

void ConferenceCore::setSelf(QSharedPointer<ConferenceCore> me) {
	mConferenceModelConnection = QSharedPointer<SafeConnection<ConferenceCore, ConferenceModel>>(
	    new SafeConnection<ConferenceCore, ConferenceModel>(me, mConferenceModel), &QObject::deleteLater);
	// mCallModelConnection->makeConnectToCore(&CallCore::lSetMicrophoneMuted, [this](bool isMuted) {
	//	mCallModelConnection->invokeToModel([this, isMuted]() { mCallModel->setMicrophoneMuted(isMuted); });
	// });
}

bool ConferenceCore::updateLocalParticipant() { // true if changed
	return false;
}

QString ConferenceCore::getSubject() const {
	return mSubject;
}
QDateTime ConferenceCore::getStartDate() const {
	return mStartDate;
}

Q_INVOKABLE qint64 ConferenceCore::getElapsedSeconds() const {
	return 0;
}
// Q_INVOKABLE ParticipantModel *getLocalParticipant() const;
// ParticipantListModel *getParticipantListModel() const;
// std::list<std::shared_ptr<linphone::Participant>>
// getParticipantList() const; // SDK exclude me. We want to get ALL participants.
int ConferenceCore::getParticipantDeviceCount() const {
	return 0;
}

void ConferenceCore::setIsReady(bool state) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mIsReady != state) {
		mIsReady = state;
		isReadyChanged();
	}
}
