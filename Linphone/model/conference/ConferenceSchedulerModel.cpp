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

#include "ConferenceSchedulerModel.hpp"

#include <QDebug>

#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(ConferenceSchedulerModel)

ConferenceSchedulerModel::ConferenceSchedulerModel(
    const std::shared_ptr<linphone::ConferenceScheduler> &conferenceScheduler, QObject *parent)
    : ::Listener<linphone::ConferenceScheduler, linphone::ConferenceSchedulerListener>(conferenceScheduler, parent) {
	mustBeInLinphoneThread(getClassName());
	auto defaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
	assert(defaultAccount);
	mMonitor->setAccount(CoreModel::getInstance()->getCore()->getDefaultAccount());
}

ConferenceSchedulerModel::~ConferenceSchedulerModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

QString ConferenceSchedulerModel::getUri() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto uriAddr = mMonitor->getInfo() ? mMonitor->getInfo()->getUri() : nullptr;
	if (uriAddr) {
		return Utils::coreStringToAppString(uriAddr->asString());
	} else return QString();
}

linphone::ConferenceScheduler::State ConferenceSchedulerModel::getState() const {
	return mState;
}

std::shared_ptr<const linphone::ConferenceInfo> ConferenceSchedulerModel::getConferenceInfo() const {
	return mMonitor->getInfo();
}

void ConferenceSchedulerModel::setInfo(const std::shared_ptr<linphone::ConferenceInfo> &confInfo) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->setInfo(confInfo);
}

void ConferenceSchedulerModel::cancelConference(const std::shared_ptr<linphone::ConferenceInfo> &confInfo) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->cancelConference(confInfo);
}

void ConferenceSchedulerModel::onStateChanged(const std::shared_ptr<linphone::ConferenceScheduler> &conferenceScheduler,
                                              linphone::ConferenceScheduler::State state) {
	mState = state;
	emit stateChanged(state);
}

void ConferenceSchedulerModel::onInvitationsSent(
    const std::shared_ptr<linphone::ConferenceScheduler> &conferenceScheduler,
    const std::list<std::shared_ptr<linphone::Address>> &failedInvitations) {
	emit invitationsSent(failedInvitations);
}
