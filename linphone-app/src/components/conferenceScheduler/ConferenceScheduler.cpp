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

#include "ConferenceScheduler.hpp"
#include "ConferenceSchedulerListener.hpp"

#include <QQmlApplicationEngine>
#include "app/App.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"

void ConferenceScheduler::connectTo(ConferenceSchedulerListener * listener){
	connect(listener, &ConferenceSchedulerListener::stateChanged, this, &ConferenceScheduler::onStateChanged);
	connect(listener, &ConferenceSchedulerListener::invitationsSent, this, &ConferenceScheduler::onInvitationsSent);
}

// =============================================================================
QSharedPointer<ConferenceScheduler> ConferenceScheduler::create( QObject *parent){
	return QSharedPointer<ConferenceScheduler>::create(parent);
}

ConferenceScheduler::ConferenceScheduler (QObject * parent) : QObject(parent){
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mConferenceScheduler = CoreManager::getInstance()->getCore()->createConferenceScheduler();
	qDebug() << "Create Scheduler with this account : " << CoreManager::getInstance()->getCore()->getDefaultAccount()->getContactAddress()->asString().c_str();
	mConferenceScheduler->setAccount(CoreManager::getInstance()->getCore()->getDefaultAccount());
	mConferenceSchedulerListener = std::make_shared<ConferenceSchedulerListener>();
	connectTo(mConferenceSchedulerListener.get());
	mConferenceScheduler->addListener(mConferenceSchedulerListener);
}

ConferenceScheduler::~ConferenceScheduler () {
	mConferenceScheduler->removeListener(mConferenceSchedulerListener);
}

std::shared_ptr<linphone::ConferenceScheduler> ConferenceScheduler::getConferenceScheduler(){
	return mConferenceScheduler;
}

void ConferenceScheduler::onStateChanged(linphone::ConferenceScheduler::State state) {
	qDebug() << "ConferenceScheduler::onStateChanged : " << (int)state;
	emit stateChanged(state);
	if( state == linphone::ConferenceScheduler::State::Ready) {
		emit CoreManager::getInstance()->getHandlers()->conferenceInfoReceived(mConferenceScheduler->getInfo());
		if( (mSendInvite & 1) == 1){
			std::shared_ptr<linphone::ChatRoomParams> params = CoreManager::getInstance()->getCore()->createDefaultChatRoomParams();
			params->setBackend(linphone::ChatRoomBackend::Basic);
			mConferenceScheduler->sendInvitations(params);
		}
	}
}

void ConferenceScheduler::onInvitationsSent( const std::list<std::shared_ptr<linphone::Address>> & failedInvitations) {
	qDebug() << "ConferenceScheduler::onInvitationsSent";
	emit invitationsSent(failedInvitations);
}
