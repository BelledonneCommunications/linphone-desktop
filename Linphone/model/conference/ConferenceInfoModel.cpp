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

#include "ConferenceInfoModel.hpp"

#include <QDebug>

#include "core/participant/ParticipantList.hpp"
#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(ConferenceInfoModel)

ConferenceInfoModel::ConferenceInfoModel(const std::shared_ptr<linphone::ConferenceInfo> &conferenceInfo,
                                         QObject *parent)
    : mConferenceInfo(conferenceInfo) {
	mustBeInLinphoneThread(getClassName());
}

ConferenceInfoModel::~ConferenceInfoModel() {
	mustBeInLinphoneThread("~" + getClassName());
	if (mConferenceSchedulerModel) mConferenceSchedulerModel->removeListener();
}

void ConferenceInfoModel::createConferenceScheduler() {
	mustBeInLinphoneThread(getClassName() + "::createConferenceScheduler()");
}

std::shared_ptr<ConferenceSchedulerModel> ConferenceInfoModel::getConferenceScheduler() const {
	return mConferenceSchedulerModel;
}

void ConferenceInfoModel::setConferenceScheduler(const std::shared_ptr<ConferenceSchedulerModel> &model) {
	if (mConferenceSchedulerModel != model) {
		if (mConferenceSchedulerModel) {
			disconnect(mConferenceSchedulerModel.get(), &ConferenceSchedulerModel::stateChanged, this, nullptr);
			disconnect(mConferenceSchedulerModel.get(), &ConferenceSchedulerModel::invitationsSent, this, nullptr);
			mConferenceSchedulerModel->removeListener();
		}
		mConferenceSchedulerModel = model;
		connect(mConferenceSchedulerModel.get(), &ConferenceSchedulerModel::stateChanged,
		        [this](linphone::ConferenceScheduler::State state) {
			        if (state == linphone::ConferenceScheduler::State::Ready && mInviteEnabled) {
				        auto params = CoreModel::getInstance()->getCore()->createDefaultChatRoomParams();
				        mConferenceSchedulerModel->getMonitor()->sendInvitations(params);
			        }
			        emit schedulerStateChanged(state);
		        });
		connect(mConferenceSchedulerModel.get(), &ConferenceSchedulerModel::invitationsSent, this,
		        &ConferenceInfoModel::invitationsSent);
		mConferenceSchedulerModel->setSelf(mConferenceSchedulerModel);
	}
}

QDateTime ConferenceInfoModel::getDateTime() const {
	return QDateTime::fromMSecsSinceEpoch(mConferenceInfo->getDateTime() * 1000, Qt::LocalTime);
}

int ConferenceInfoModel::getDuration() const {
	return mConferenceInfo->getDuration();
}

QDateTime ConferenceInfoModel::getEndTime() const {
	return getDateTime().addSecs(mConferenceInfo->getDuration());
}

QString ConferenceInfoModel::getSubject() const {
	return Utils::coreStringToAppString(mConferenceInfo->getSubject());
}

linphone::ConferenceInfo::State ConferenceInfoModel::getState() const {
	return mConferenceInfo->getState();
}

QString ConferenceInfoModel::getOrganizerName() const {
	auto organizer = mConferenceInfo->getOrganizer();
	auto name = Utils::coreStringToAppString(organizer->getDisplayName());
	if (name.isEmpty()) name = ToolModel::getDisplayName(Utils::coreStringToAppString(organizer->asStringUriOnly()));
	return name;
}

QString ConferenceInfoModel::getOrganizerAddress() const {
	return Utils::coreStringToAppString(mConferenceInfo->getOrganizer()->asStringUriOnly());
}

QString ConferenceInfoModel::getDescription() const {
	return Utils::coreStringToAppString(mConferenceInfo->getSubject());
}

QString ConferenceInfoModel::getUri() const {
	if (auto uriAddr = mConferenceInfo->getUri()) {
		return Utils::coreStringToAppString(uriAddr->asString());
	} else return QString();
}

std::list<std::shared_ptr<linphone::ParticipantInfo>> ConferenceInfoModel::getParticipantInfos() const {
	return mConferenceInfo->getParticipantInfos();
}

bool ConferenceInfoModel::inviteEnabled() const {
	return mInviteEnabled;
}

void ConferenceInfoModel::setDateTime(const QDateTime &date) {
	mConferenceInfo->setDateTime(date.isValid() ? date.toMSecsSinceEpoch() / 1000 : -1); // toMSecsSinceEpoch() is UTC
	emit dateTimeChanged(date);
}

void ConferenceInfoModel::setDuration(int duration) {
	mConferenceInfo->setDuration(duration);
	emit durationChanged(duration);
}

void ConferenceInfoModel::setSubject(const QString &subject) {
	mConferenceInfo->setSubject(Utils::appStringToCoreString(subject));
	emit subjectChanged(subject);
}

void ConferenceInfoModel::setOrganizer(const QString &organizerAddress) {
	auto linAddr = ToolModel::interpretUrl(organizerAddress);
	if (linAddr) {
		mConferenceInfo->setOrganizer(linAddr);
		emit organizerChanged(organizerAddress);
	}
}

void ConferenceInfoModel::setDescription(const QString &description) {
	mConferenceInfo->setDescription(Utils::appStringToCoreString(description));
	emit descriptionChanged(description);
}

void ConferenceInfoModel::setParticipantInfos(
    const std::list<std::shared_ptr<linphone::ParticipantInfo>> &participantInfos) {
	mConferenceInfo->setParticipantInfos(participantInfos);
	emit participantsChanged();
}

void ConferenceInfoModel::deleteConferenceInfo() {
	CoreModel::getInstance()->getCore()->deleteConferenceInformation(mConferenceInfo);
	emit conferenceInfoDeleted();
}

void ConferenceInfoModel::cancelConference() {
	if (!mConferenceSchedulerModel) return;
	mConferenceSchedulerModel->cancelConference(mConferenceInfo);
	emit conferenceInfoCanceled();
}

void ConferenceInfoModel::updateConferenceInfo() {
	mConferenceSchedulerModel->setInfo(mConferenceInfo);
}

void ConferenceInfoModel::enableInvite(bool enable) {
	if (mInviteEnabled != enable) {
		mInviteEnabled = enable;
		emit inviteEnabledChanged(mInviteEnabled);
	}
}
