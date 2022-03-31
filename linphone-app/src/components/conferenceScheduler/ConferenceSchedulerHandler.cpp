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

#include "ConferenceSchedulerHandler.hpp"

#include <QQmlApplicationEngine>
#include "app/App.hpp"
#include "components/core/CoreManager.hpp"

// =============================================================================
std::shared_ptr<ConferenceSchedulerHandler> ConferenceSchedulerHandler::create( QObject *parent){
	std::shared_ptr<ConferenceSchedulerHandler> model = std::make_shared<ConferenceSchedulerHandler>(parent);
	if(model){
		model->mSelf = model;
		model->mConferenceScheduler->addListener(model);
		return model;
	}
	return nullptr;
}

ConferenceSchedulerHandler::ConferenceSchedulerHandler (QObject * parent) : QObject(parent){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mConferenceScheduler = CoreManager::getInstance()->getCore()->createConferenceScheduler();
}

ConferenceSchedulerHandler::~ConferenceSchedulerHandler () {
}

std::shared_ptr<linphone::ConferenceScheduler> ConferenceSchedulerHandler::getConferenceScheduler(){
	return mConferenceScheduler;
}

void ConferenceSchedulerHandler::onStateChanged(const std::shared_ptr<linphone::ConferenceScheduler> & conferenceScheduler, linphone::ConferenceSchedulerState state) {
	emit stateChanged(state);
	qWarning() << "ConferenceSchedulerHandler::onStateChanged : " << (int)state;
	if( state == linphone::ConferenceSchedulerState::Ready) {
		std::shared_ptr<linphone::ChatRoomParams> params = CoreManager::getInstance()->getCore()->createDefaultChatRoomParams();
		params->setBackend(linphone::ChatRoomBackend::Basic);
		mConferenceScheduler->sendInvitations(params);
	}
}

void ConferenceSchedulerHandler::onInvitationsSent(const std::shared_ptr<linphone::ConferenceScheduler> & conferenceScheduler, const std::list<std::shared_ptr<linphone::Address>> & failedInvitations) {
	emit invitationsSent(failedInvitations);
}