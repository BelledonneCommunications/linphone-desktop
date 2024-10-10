/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include "ParticipantProxy.hpp"
#include "ParticipantList.hpp"

// #include "core/conference/ConferenceCore.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"

#include "ParticipantList.hpp"
#include "core/participant/ParticipantCore.hpp"

#include <QDebug>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(ParticipantProxy)

ParticipantProxy::ParticipantProxy(QObject *parent) : LimitProxy(parent) {
	mParticipants = ParticipantList::create();
	connect(this, &ParticipantProxy::chatRoomModelChanged, this, &ParticipantProxy::countChanged);
	connect(this, &ParticipantProxy::conferenceModelChanged, this, &ParticipantProxy::countChanged);
	setSourceModels(new SortFilterList(mParticipants.get(), Qt::AscendingOrder));
}

ParticipantProxy::~ParticipantProxy() {
}

CallGui *ParticipantProxy::getCurrentCall() const {
	return mCurrentCall;
}

void ParticipantProxy::setCurrentCall(CallGui *call) {
	lDebug() << "[ParticipantProxy] set current call " << this << " => " << call;
	if (mCurrentCall != call) {
		CallCore *callCore = nullptr;
		if (mCurrentCall) {
			callCore = mCurrentCall->getCore();
			if (callCore) callCore->disconnect(mParticipants.get());
			callCore = nullptr;
		}
		mCurrentCall = call;
		if (mCurrentCall) callCore = mCurrentCall->getCore();
		if (callCore) {
			connect(callCore, &CallCore::conferenceChanged, mParticipants.get(), [this]() {
				auto conference = mCurrentCall->getCore()->getConferenceCore();
				lDebug() << "[ParticipantDeviceProxy] set conference " << this << " => " << conference;
				mParticipants->setConferenceModel(conference ? conference->getModel() : nullptr);
				// mParticipants->lSetConferenceModel(conference ? conference->getModel() : nullptr);
			});
			auto conference = callCore->getConferenceCore();
			lDebug() << "[ParticipantDeviceProxy] set conference " << this << " => " << conference;
			mParticipants->setConferenceModel(conference ? conference->getModel() : nullptr);
			// mParticipants->lSetConferenceModel(conference ? conference->getModel() : nullptr);
		}
		emit currentCallChanged();
	}
}

bool ParticipantProxy::getShowMe() const {
	return dynamic_cast<SortFilterList *>(sourceModel())->mShowMe;
}

// -----------------------------------------------------------------------------

// void ParticipantProxy::setChatRoomModel(ChatRoomModel *chatRoomModel) {
// if (!mChatRoomModel || mChatRoomModel != chatRoomModel) {
// 	mChatRoomModel = chatRoomModel;
// 	if (mChatRoomModel) {
// 		auto participants = mChatRoomModel->getParticipantList();
// 		connect(participants, &ParticipantList::countChanged, this, &ParticipantProxy::countChanged);
// 		setSourceModel(participants);
// 		emit participantListChanged();
// 		for (int i = 0; i < participants->getCount(); ++i) {
// 			auto participant = participants->getAt<ParticipantCore>(i);
// 			connect(participant.get(), &ParticipantCore::invitationTimeout, this, &ParticipantProxy::removeModel);
// 			emit addressAdded(participant->getSipAddress());
// 		}
// 	} else if (!sourceModel()) {
// 		auto model = new ParticipantList((ChatRoomModel *)nullptr, this);
// 		connect(model, &ParticipantList::countChanged, this, &ParticipantProxy::countChanged);
// 		setSourceModel(model);
// 		emit participantListChanged();
// 	}
// 	sort(0);
// 	emit chatRoomModelChanged();
// }
// }

void ParticipantProxy::setShowMe(const bool &show) {
	auto list = dynamic_cast<SortFilterList *>(sourceModel());
	if (list->mShowMe != show) {
		list->mShowMe = show;
		emit showMeChanged();
		invalidateFilter();
	}
}

void ParticipantProxy::addAddress(const QString &address) {
	mParticipants->addAddress(address);
}

void ParticipantProxy::addAddresses(const QStringList &addresses) {
	for (auto &address : addresses)
		mParticipants->addAddress(address);
}

void ParticipantProxy::removeParticipant(ParticipantCore *participant) {
	if (participant) {
		mParticipants->remove(participant);
	}
}

void ParticipantProxy::setParticipantAdminStatus(ParticipantCore *participant, bool status) {
	emit mParticipants->lSetParticipantAdminStatus(participant, status);
}

// -----------------------------------------------------------------------------

bool ParticipantProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	if (mShowMe) return true;
	else {
		auto participant = qobject_cast<ParticipantList *>(sourceModel())->getAt<ParticipantCore>(sourceRow);
		return !participant->isMe();
	}
}

bool ParticipantProxy::SortFilterList::lessThan(const QModelIndex &left, const QModelIndex &right) const {
	auto l = getItemAtSource<ParticipantList, ParticipantCore>(left.row());
	auto r = getItemAtSource<ParticipantList, ParticipantCore>(right.row());

	return l->getCreationTime() > r->getCreationTime() || r->isMe();
}
