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
	// mChatRoomModel = nullptr;
	// mConferenceModel = nullptr;
}

void ParticipantList::setSelf(QSharedPointer<ParticipantList> me) {
	if (mConferenceModelConnection) mConferenceModelConnection->disconnect();
	mConferenceModelConnection = QSharedPointer<SafeConnection<ParticipantList, ConferenceModel>>(
	    new SafeConnection<ParticipantList, ConferenceModel>(me, mConferenceModel), &QObject::deleteLater);
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
					resetData();
					add(*participantList);
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
	qDebug() << "[ParticipantList] : set Conference " << mConferenceModel.get();
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
	auto testAddress = ToolModel::interpretUrl(address);
	bool exists = false;
	for (auto itParticipant = mList.begin(); !exists && itParticipant != mList.end(); ++itParticipant)
		exists = testAddress->weakEqual(
		    ToolModel::interpretUrl(itParticipant->objectCast<ParticipantCore>()->getSipAddress()));
	return exists;
}

// void ParticipantList::updateParticipants() {
// 	if (/*mChatRoomModel ||*/ mConferenceModel) {
// 		bool changed = false;
// 		mConferenceModel->getMonitor()->getParticipantList();
// 		// auto dbParticipants = (/*mChatRoomModel ? mChatRoomModel->getParticipants() :*/ mConferenceModel->get());
// 		// Remove left participants
// 		auto itParticipant = mList.begin();
// 		while (itParticipant != mList.end()) {
// 			auto itDbParticipant = dbParticipants.begin();
// 			while (
// 			    itDbParticipant != dbParticipants.end() &&
// 			    (itParticipant->objectCast<ParticipantCore>()->getParticipant() &&
// 			         !(*itDbParticipant)
// 			              ->getAddress()
// 			              ->weakEqual(itParticipant->objectCast<ParticipantCore>()->getParticipant()->getAddress()) ||
// 			     !itParticipant->objectCast<ParticipantCore>()->getParticipant() &&
// 			         !(*itDbParticipant)
// 			              ->getAddress()
// 			              ->weakEqual(
// 			                  Utils::interpretUrl(itParticipant->objectCast<ParticipantCore>()->getSipAddress())))) {
// 				++itDbParticipant;
// 			}
// 			if (itDbParticipant == dbParticipants.end()) {
// 				int row = itParticipant - mList.begin();
// 				if (!changed) emit layoutAboutToBeChanged();
// 				beginRemoveRows(QModelIndex(), row, row);
// 				itParticipant = mList.erase(itParticipant);
// 				endRemoveRows();
// 				changed = true;
// 			} else ++itParticipant;
// 		}
// 		// Add new
// 		for (auto dbParticipant : dbParticipants) {
// 			auto itParticipant = mList.begin();
// 			while (itParticipant != mList.end() &&
// 			       ((itParticipant->objectCast<ParticipantCore>()->getParticipant() &&
// 			         !dbParticipant->getAddress()->weakEqual(
// 			             itParticipant->objectCast<ParticipantCore>()->getParticipant()->getAddress()))

// 			        || (!itParticipant->objectCast<ParticipantCore>()->getParticipant() &&
// 			            !dbParticipant->getAddress()->weakEqual(
// 			                Utils::interpretUrl(itParticipant->objectCast<ParticipantCore>()->getSipAddress()))))) {
// 				++itParticipant;
// 			}
// 			if (itParticipant == mList.end()) {
// 				auto participant = QSharedPointer<ParticipantCore>::create(dbParticipant);
// 				add(participant);
// 				changed = true;
// 			} else if (!itParticipant->objectCast<ParticipantCore>()->getParticipant() ||
// 			           itParticipant->objectCast<ParticipantCore>()->getParticipant() != dbParticipant) {
// 				itParticipant->objectCast<ParticipantCore>()->setParticipant(dbParticipant);
// 				changed = true;
// 			}
// 		}
// 		if (changed) {
// 			emit layoutChanged();
// 			emit participantsChanged();
// 			emit countChanged();
// 		}
// 	}
// }

// void ParticipantList::add(QSharedPointer<ParticipantCore> participant) {
// 	int row = mList.count();
// 	connect(this, &ParticipantList::deviceSecurityLevelChanged, participant.get(),
// 	        &ParticipantCore::onDeviceSecurityLevelChanged);
// 	connect(this, &ParticipantList::securityLevelChanged, participant.get(), &ParticipantCore::onSecurityLevelChanged);
// 	connect(participant.get(), &ParticipantCore::updateAdminStatus, this, &ParticipantList::setAdminStatus);
// 	ProxyListModel::add(participant);
// 	emit participantsChanged();
// }

// void ParticipantList::add(const std::shared_ptr<const linphone::Participant> &participant) {
// 	updateParticipants();
// }

// void ParticipantList::add(const std::shared_ptr<const linphone::Address> &participantAddress) {
// 	add((mChatRoomModel ? mChatRoomModel->getChatRoom()->findParticipant(participantAddress->clone())
// 	                    : mConferenceModel->getConference()->findParticipant(participantAddress)));
// }

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
		// if (mChatRoomModel && mChatRoomModel->getChatRoom()) { // Invite and wait for its creation
		// participant->startInvitation();
		// mChatRoomModel->getChatRoom()->addParticipant(Utils::interpretUrl(address));
		// }
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
			// else {
			// 	runningCallsToAdd.push_back(*haveCall);
			// 	mConferenceModel->addParticipants(runningCallsToAdd);
			// }
			/*
			    std::list<std::shared_ptr<linphone::Address>> addressesToInvite;
			    addressesToInvite.push_back(addressToInvite);
			    auto callParameters =
			   CoreManager::getInstance()->getCore()->createCallParams(mConferenceModel->getConference()->getCall());
			    mConferenceModel->getConference()->inviteParticipants(addressesToInvite, callParameters);*/
		}
		emit participant->lStartInvitation();
		emit countChanged();
		// emit addressAdded(address);
	}
}

// const QSharedPointer<ParticipantCore>
// ParticipantList::getParticipant(const std::shared_ptr<const linphone::Address> &address) const {
// 	if (address) {
// 		auto itParticipant =
// 		    std::find_if(mList.begin(), mList.end(), [address](const QSharedPointer<QObject> &participant) {
// 			    return
// participant.objectCast<ParticipantCore>()->getParticipant()->getAddress()->weakEqual(address);
// 		    });
// 		if (itParticipant == mList.end()) return nullptr;
// 		else return itParticipant->objectCast<ParticipantCore>();
// 	} else return nullptr;
// }
// const QSharedPointer<ParticipantCore>
// ParticipantList::getParticipant(const std::shared_ptr<const linphone::Participant> &pParticipant) const {
// 	if (pParticipant) {
// 		auto itParticipant =
// 		    std::find_if(mList.begin(), mList.end(), [pParticipant](const QSharedPointer<QObject> &participant) {
// 			    return participant.objectCast<ParticipantCore>()->getParticipant() == pParticipant;
// 		    });
// 		if (itParticipant == mList.end()) return nullptr;
// 		else return itParticipant->objectCast<ParticipantCore>();
// 	} else return nullptr;
// }

//-------------------------------------------------------------

// void ParticipantList::setAdminStatus(const std::shared_ptr<linphone::Participant> participant, const bool
// &isAdmin) {
// 	// if (mChatRoomModel) mChatRoomModel->getChatRoom()->setParticipantAdminStatus(participant, isAdmin);
// 	// if (mConferenceModel) mConferenceModel->getConference()->setParticipantAdminStatus(participant, isAdmin);
// }

// void ParticipantList::onSecurityEvent(const std::shared_ptr<const linphone::EventLog> &eventLog) {
// 	auto address = eventLog->getParticipantAddress();
// 	if (address) {
// 		// auto participant = getParticipant(address);
// 		// if (participant) {
// 		// 	emit participant->securityLevelChanged();
// 		// }
// 	} else {
// 		address = eventLog->getDeviceAddress();
// 		// Looping on all participant ensure to get all devices. Can be optimized if Device address is unique : Gain
// 		// 2n operations.
// 		if (address) emit deviceSecurityLevelChanged(address);
// 	}
// }

// void ParticipantList::onConferenceJoined() {
// 	// updateParticipants();
// }

// void ParticipantList::onParticipantAdded(const std::shared_ptr<const linphone::EventLog> &eventLog) {
// 	qDebug() << "onParticipantAdded event: " << eventLog->getParticipantAddress()->asString().c_str();
// 	// add(eventLog->getParticipantAddress());
// }

// void ParticipantList::onParticipantAdded(const std::shared_ptr<const linphone::Participant> &participant) {
// 	qDebug() << "onParticipantAdded part: " << participant->getAddress()->asString().c_str();
// 	// add(participant);
// }

// void ParticipantList::onParticipantAdded(const std::shared_ptr<const linphone::Address> &address) {
// 	qDebug() << "onParticipantAdded addr: " << address->asString().c_str();
// 	// add(address);
// }

// void ParticipantList::onParticipantRemoved(const std::shared_ptr<const linphone::EventLog> &eventLog) {
// 	onParticipantRemoved(eventLog->getParticipantAddress());
// }

// void ParticipantList::onParticipantRemoved(const std::shared_ptr<const linphone::Participant> &participant) {
// 	// auto p = getParticipant(participant);
// 	// if (p) remove(p.get());
// }

// void ParticipantList::onParticipantRemoved(const std::shared_ptr<const linphone::Address> &address) {
// 	// auto participant = getParticipant(address);
// 	// if (participant) remove(participant.get());
// }

// void ParticipantList::onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::EventLog> &eventLog)
// { 	onParticipantAdminStatusChanged(eventLog->getParticipantAddress());
// }
// void ParticipantList::onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::Participant>
// &participant) {
// 	// auto p = getParticipant(participant);
// 	// if (participant) emit p->adminStatusChanged(); // Request to participant to update its status from its data
// }
// void ParticipantList::onParticipantAdminStatusChanged(const std::shared_ptr<const linphone::Address> &address) {
// 	// auto participant = getParticipant(address);
// 	// if (participant)
// 	// emit participant->adminStatusChanged(); // Request to participant to update its status from its data
// }
// void ParticipantList::onParticipantDeviceAdded(const std::shared_ptr<const linphone::EventLog> &eventLog) {
// 	// auto participant = getParticipant(eventLog->getParticipantAddress());
// 	// if (participant) {
// 	// emit participant->deviceCountChanged();
// 	// }
// }
// void ParticipantList::onParticipantDeviceRemoved(const std::shared_ptr<const linphone::EventLog> &eventLog) {
// 	// auto participant = getParticipant(eventLog->getParticipantAddress());
// 	// if (participant) {
// 	// emit participant->deviceCountChanged();
// 	// }
// }
// void ParticipantList::onParticipantRegistrationSubscriptionRequested(
//     const std::shared_ptr<const linphone::Address> &participantAddress) {
// }
// void ParticipantList::onParticipantRegistrationUnsubscriptionRequested(
//     const std::shared_ptr<const linphone::Address> &participantAddress) {
// }

// void ParticipantList::onStateChanged() {
// 	// if (mConferenceModel) {
// 	// if (mConferenceModel->getConference()->getState() == linphone::Conference::State::Created) {
// 	// updateParticipants();
// 	// }
// 	// }
// }
