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

#include "ParticipantDeviceProxy.hpp"
#include "ParticipantDeviceList.hpp"
#include "core/App.hpp"

#include <QQmlApplicationEngine>

// =============================================================================

ParticipantDeviceProxy::ParticipantDeviceProxy(QObject *parent) : SortFilterProxy(parent) {
	mDeleteSourceModel = true;
	mList = ParticipantDeviceList::create();
	setSourceModel(mList.get());
}

ParticipantDeviceProxy::~ParticipantDeviceProxy() {
}

bool ParticipantDeviceProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	const QModelIndex index = mList->index(sourceRow, 0, sourceParent);
	const ParticipantDeviceCore *device = index.data().value<ParticipantDeviceCore *>();
	return device && (isShowMe() /*|| !(device->isMe() && device->isLocal())*/);
}

bool ParticipantDeviceProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const {
	const ParticipantDeviceCore *deviceA = sourceModel()->data(left).value<ParticipantDeviceCore *>();
	const ParticipantDeviceCore *deviceB = sourceModel()->data(right).value<ParticipantDeviceCore *>();
	// 'me' at end (for grid).
	return /*deviceB->isLocal() || !deviceA->isLocal() && deviceB->isMe() ||*/ left.row() < right.row();
}
//---------------------------------------------------------------------------------

ParticipantDeviceCore *ParticipantDeviceProxy::getAt(int row) {
	if (row >= 0) {
		QModelIndex sourceIndex = mapToSource(this->index(row, 0));
		return sourceModel()->data(sourceIndex).value<ParticipantDeviceCore *>();
	} else return nullptr;
}

ParticipantDeviceCore *ParticipantDeviceProxy::getActiveSpeakerModel() {
	return mList->getActiveSpeakerModel();
}

CallModel *ParticipantDeviceProxy::getCallModel() const {
	return mCallModel;
}

ParticipantDeviceCore *ParticipantDeviceProxy::getMe() const {
	return mList->getMe().get();
}

bool ParticipantDeviceProxy::isShowMe() const {
	return mShowMe;
}

void ParticipantDeviceProxy::connectTo(ParticipantDeviceList *model) {
	connect(model, &ParticipantDeviceList::countChanged, this, &ParticipantDeviceProxy::onCountChanged);
	connect(model, &ParticipantDeviceList::participantSpeaking, this, &ParticipantDeviceProxy::onParticipantSpeaking);
	connect(model, &ParticipantDeviceList::conferenceCreated, this, &ParticipantDeviceProxy::conferenceCreated);
	connect(model, &ParticipantDeviceList::meChanged, this, &ParticipantDeviceProxy::meChanged);
	connect(model, &ParticipantDeviceList::activeSpeakerChanged, this, &ParticipantDeviceProxy::activeSpeakerChanged);
}
void ParticipantDeviceProxy::setCallModel(CallModel *callModel) {
	setFilterType(1);
	mCallModel = callModel;
	deleteSourceModel();
	auto newSourceModel = new ParticipantDeviceList(mCallModel);
	connectTo(newSourceModel);
	setSourceModel(newSourceModel);
	mDeleteSourceModel = true;
	sort(0);
	emit countChanged();
	emit meChanged();
}

// void ParticipantDeviceProxy::setParticipant(ParticipantCore *participantCore) {
// 	setFilterType(0);
// 	deleteSourceModel();
// 	auto newSourceModel = participant->getParticipantDevices().get();
// 	connectTo(newSourceModel);
// 	setSourceModel(newSourceModel);
// 	mDeleteSourceModel = false;
// 	sort(0);
// 	emit countChanged();
// 	emit meChanged();
// }

void ParticipantDeviceProxy::setShowMe(const bool &show) {
	if (mShowMe != show) {
		mShowMe = show;
		emit showMeChanged();
		invalidate();
	}
}

void ParticipantDeviceProxy::onCountChanged() {
	qDebug() << "Count changed : " << getCount();
}

void ParticipantDeviceProxy::onParticipantSpeaking(ParticipantDeviceCore *speakingDevice) {
	emit participantSpeaking(speakingDevice);
}
