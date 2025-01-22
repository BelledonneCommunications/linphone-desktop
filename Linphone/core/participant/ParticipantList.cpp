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

#include "ParticipantList.hpp"
#include "core/App.hpp"
#include "core/participant/ParticipantGui.hpp"
#include "model/core/CoreModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

#include <QDebug>

DEFINE_ABSTRACT_OBJECT(ParticipantList)

QSharedPointer<ParticipantList> ParticipantList::create() {
	auto model = QSharedPointer<ParticipantList>(new ParticipantList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

QSharedPointer<ParticipantList> ParticipantList::create(const std::shared_ptr<ConferenceModel> &conferenceModel) {
	auto model = create();
	model->setConferenceModel(conferenceModel);
	return model;
}

ParticipantList::ParticipantList(QObject *parent) : ListProxy(parent) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ParticipantList::~ParticipantList() {
	mList.clear();
}

void ParticipantList::setSelf(QSharedPointer<ParticipantList> me) {
	if (mConferenceModelConnection) mConferenceModelConnection->disconnect();
	mConferenceModelConnection = SafeConnection<ParticipantList, ConferenceModel>::create(me, mConferenceModel);
	if (mConferenceModel) {
		mConferenceModelConnection->makeConnectToCore(&ParticipantList::lUpdateParticipants, [this] {
			mConferenceModelConnection->invokeToModel([this]() {
				QList<QSharedPointer<ParticipantCore>> *participantList = new QList<QSharedPointer<ParticipantCore>>();
				mustBeInLinphoneThread(getClassName());
				std::list<std::shared_ptr<linphone::Participant>> participants;
				participants = mConferenceModel->getMonitor()->getParticipantList();
				for (auto it : participants) {
					auto model = ParticipantCore::create(it);
					participantList->push_back(model);
				}
				auto me = mConferenceModel->getMonitor()->getMe();
				auto meModel = ParticipantCore::create(me);
				participantList->push_back(meModel);
				mConferenceModelConnection->invokeToCore([this, participantList]() {
					mustBeInMainThread(getClassName());
					resetData<ParticipantCore>(*participantList);
					delete participantList;
				});
			});
		});

		mConferenceModelConnection->makeConnectToCore(
		    &ParticipantList::lSetParticipantAdminStatus, [this](ParticipantCore *participant, bool status) {
			    auto address = participant->getSipAddress();
			    mConferenceModelConnection->invokeToModel([this, address, status] {
				    auto participants = mConferenceModel->getMonitor()->getParticipantList();
				    for (auto &participant : participants) {
					    if (Utils::coreStringToAppString(participant->getAddress()->asStringUriOnly()) == address) {
						    mConferenceModel->setParticipantAdminStatus(participant, status);
						    return;
					    }
				    }
			    });
		    });

		mConferenceModelConnection->makeConnectToModel(&ConferenceModel::participantAdminStatusChanged,
		                                               &ParticipantList::lUpdateParticipants);

		mConferenceModelConnection->makeConnectToModel(&ConferenceModel::participantAdded,
		                                               &ParticipantList::lUpdateParticipants);
		mConferenceModelConnection->makeConnectToModel(&ConferenceModel::participantRemoved,
		                                               &ParticipantList::lUpdateParticipants);
	}
	emit lUpdateParticipants();
}

void ParticipantList::setConferenceModel(const std::shared_ptr<ConferenceModel> &conferenceModel) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	mConferenceModel = conferenceModel;
	lDebug() << "[ParticipantList] : set Conference " << mConferenceModel.get();
	if (mConferenceModelConnection && mConferenceModelConnection->mCore.lock()) { // Unsure to get myself
		auto oldConnect = mConferenceModelConnection->mCore;                      // Setself rebuild safepointer
		setSelf(mConferenceModelConnection->mCore.mQData);                        // reset connections
		oldConnect.unlock();
	}
	beginResetModel();
	mList.clear();
	endResetModel();
	if (mConferenceModel) {
		emit lUpdateParticipants();
	}
}

QVariant ParticipantList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		return QVariant::fromValue(new ParticipantGui(mList[row].objectCast<ParticipantCore>()));
	}
	return QVariant();
}

std::list<std::shared_ptr<linphone::Address>> ParticipantList::getParticipants() const {
	std::list<std::shared_ptr<linphone::Address>> participants;
	for (auto participant : mList) {
		participants.push_back(ToolModel::interpretUrl(participant.objectCast<ParticipantCore>()->getSipAddress()));
	}
	return participants;
}

bool ParticipantList::contains(const QString &address) const {
	bool exists = false;
	App::postModelBlock([this, address, &exists, participants = mList]() {
		auto testAddress = ToolModel::interpretUrl(address);
		for (auto itParticipant = participants.begin(); !exists && itParticipant != participants.end(); ++itParticipant)
			exists = testAddress->weakEqual(
			    ToolModel::interpretUrl(itParticipant->objectCast<ParticipantCore>()->getSipAddress()));
	});

	return exists;
}

void ParticipantList::remove(ParticipantCore *participant) {
	QString address = participant->getSipAddress();
	int index = 0;
	bool found = false;
	auto itParticipant = mList.begin();
	while (!found && itParticipant != mList.end()) {
		if (itParticipant->objectCast<ParticipantCore>()->getSipAddress() == address) found = true;
		else {
			++itParticipant;
			++index;
		}
	}
	if (found) {
		mConferenceModel->removeParticipant(ToolModel::interpretUrl(address));
	}
}

void ParticipantList::addAddress(const QString &address) {

	if (!contains(address)) {
		QSharedPointer<ParticipantCore> participant = QSharedPointer<ParticipantCore>::create(nullptr);
		connect(participant.get(), &ParticipantCore::invitationTimeout, this, &ParticipantList::remove);
		participant->setSipAddress(address);
		add(participant);
		if (mConferenceModel) {
			std::list<std::shared_ptr<linphone::Call>> runningCallsToAdd;
			mConferenceModelConnection->invokeToModel([this, address] {
				auto addressToInvite = ToolModel::interpretUrl(address);
				auto currentCalls = CoreModel::getInstance()->getCore()->getCalls();
				auto haveCall = std::find_if(currentCalls.begin(), currentCalls.end(),
				                             [addressToInvite](const std::shared_ptr<linphone::Call> &call) {
					                             return call->getRemoteAddress()->weakEqual(addressToInvite);
				                             });
				if (haveCall == currentCalls.end()) mConferenceModel->addParticipant(addressToInvite);
			});
		}
		emit participant->lStartInvitation();
		emit countChanged();
	}
}
