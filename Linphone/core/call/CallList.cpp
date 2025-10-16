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

#include "CallList.hpp"
#include "CallCore.hpp"
#include "CallGui.hpp"
#include "core/App.hpp"
#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(CallList)

QSharedPointer<CallList> CallList::create() {
	auto model = QSharedPointer<CallList>(new CallList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

QSharedPointer<CallCore> CallList::createCallCore(const std::shared_ptr<linphone::Call> &call) {
	auto callCore = CallCore::create(call);
	connect(callCore.get(), &CallCore::stateChanged, this, &CallList::onStateChanged);
	return callCore;
}

CallList::CallList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

CallList::~CallList() {
	mustBeInMainThread("~" + getClassName());
	mModelConnection = nullptr;
}

void CallList::setSelf(QSharedPointer<CallList> me) {
	mModelConnection = SafeConnection<CallList, CoreModel>::create(me, CoreModel::getInstance());

	mModelConnection->makeConnectToCore(&CallList::lUpdate, [this]() {
		mModelConnection->invokeToModel([this]() {
			// Avoid copy to lambdas
			QList<QSharedPointer<CallCore>> *calls = new QList<QSharedPointer<CallCore>>();
			mustBeInLinphoneThread(getClassName());
			auto linphoneCalls = CoreModel::getInstance()->getCore()->getCalls();
			auto currentCall = CoreModel::getInstance()->getCore()->getCurrentCall();
			QSharedPointer<CallCore> currentCallCore;
			for (auto it : linphoneCalls) {
				auto model = createCallCore(it);
				if (it == currentCall) currentCallCore = model;
				calls->push_back(model);
			}
			mModelConnection->invokeToCore([this, calls, currentCallCore]() {
				mustBeInMainThread(getClassName());
				resetData<CallCore>(*calls);
				setHaveCall(calls->size() > 0);
				setCurrentCallCore(currentCallCore);
				delete calls;
			});
		});
	});
	mModelConnection->makeConnectToCore(&CallList::lMergeAll, [this]() {
		mModelConnection->invokeToModel([this]() {
			auto core = CoreModel::getInstance()->getCore();
			auto currentCalls = CoreModel::getInstance()->getCore()->getCalls();
			std::shared_ptr<linphone::Conference> conference = nullptr;

			// Search a managable conference from calls
			for (auto call : currentCalls) {
				auto dbConference = call->getConference();
				if (dbConference && dbConference->getMe()->isAdmin()) {
					conference = dbConference;
					break;
				}
			}

			auto currentCall = CoreModel::getInstance()->getCore()->getCurrentCall();
			bool enablingVideo = false;
			if (currentCall) enablingVideo = currentCall->getCurrentParams()->videoEnabled();
			if (!conference) {
				auto parameters = core->createConferenceParams(conference);
				auto audioVideoConfFactoryUri =
				    core->getDefaultAccount()->getParams()->getAudioVideoConferenceFactoryAddress();
				if (audioVideoConfFactoryUri) {
					parameters->setConferenceFactoryAddress(audioVideoConfFactoryUri);
					parameters->setSubject("Meeting");
				} else {
					parameters->setSubject("Local meeting");
				}
				parameters->enableVideo(enablingVideo);
				conference = core->createConferenceWithParams(parameters);
			}

			std::list<std::shared_ptr<linphone::Address>> allLinphoneAddresses;
			std::list<std::shared_ptr<linphone::Address>> newCalls;
			std::list<std::shared_ptr<linphone::Call>> runningCallsToAdd;

			for (auto call : currentCalls) {
				if (!call->getConference()) {
					runningCallsToAdd.push_back(call);
				}
			}

			// 1) Add running calls
			if (runningCallsToAdd.size() > 0) {
				conference->addParticipants(runningCallsToAdd);
			}

			// emit lUpdate();
		});
	});

	mModelConnection->makeConnectToModel(&CoreModel::firstCallStarted,
	                                     [this]() { mModelConnection->invokeToCore([this]() { lUpdate(); }); });
	mModelConnection->makeConnectToModel(&CoreModel::lastCallEnded, [this]() {
		mModelConnection->invokeToCore([this]() {
			setHaveCall(false);
			setCurrentCall(nullptr);
		});
	});
	mModelConnection->makeConnectToModel(&CoreModel::callCreated, [this](const std::shared_ptr<linphone::Call> &call) {
		auto model = createCallCore(call);
		mModelConnection->invokeToCore([this, model]() {
			// We set the current here and not on firstCallStarted event because we don't want to add unicity check
			// while keeping the same model between list and current call.
			if (mList.size() == 0) setCurrentCallCore(model);
			add(model);
		});
	});
	lUpdate();
}

QSharedPointer<CallCore> CallList::getCurrentCallCore() const {
	return mCurrentCall;
}

CallGui *CallList::getCurrentCall() const {
	auto call = getCurrentCallCore();
	if (call) return new CallGui(call);
	else return nullptr;
}

void CallList::setCurrentCall(CallGui *callGui) {
	setCurrentCallCore(callGui ? callGui->mCore : nullptr);
}

void CallList::setCurrentCallCore(QSharedPointer<CallCore> call) {
	if (mCurrentCall != call) {
		mCurrentCall = call;
		emit currentCallChanged();
	}
}

bool CallList::getHaveCall() const {
	return mHaveCall;
}

void CallList::setHaveCall(bool haveCall) {
	if (mHaveCall != haveCall) {
		mHaveCall = haveCall;
		emit haveCallChanged();
	}
}

QSharedPointer<CallCore> CallList::getNextCall() {
	auto currentCall = getCurrentCallCore();
	for (auto &item : getSharedList<CallCore>()) {
		if (item != currentCall) return item;
	}
	return nullptr;
}

QSharedPointer<CallCore> CallList::getFirstIncommingPendingCall() {
	auto callList = getSharedList<CallCore>();
	auto it = std::find_if(callList.begin(), callList.end(), [](const QSharedPointer<CallCore> call) {
		return call->getState() == LinphoneEnums::CallState::IncomingReceived;
	});
	if (it == callList.end()) return nullptr;
	return *it;
}

void CallList::onStateChanged() {
	auto call = dynamic_cast<CallCore *>(sender());
	switch (call->getState()) {
		case LinphoneEnums::CallState::StreamsRunning:
		case LinphoneEnums::CallState::Resuming: {
			auto sharedCall = get(call);
			setCurrentCallCore(sharedCall ? sharedCall.objectCast<CallCore>() : nullptr);
			break;
		}
		case LinphoneEnums::CallState::Released: {
			auto sharedCall = get(call);
			if (sharedCall) {
				auto currentCall = getCurrentCallCore();
				sharedCall->disconnect(this);
				// Update current call
				if (currentCall == sharedCall) {
					auto nextCall = getNextCall();
					if (nextCall) {
						// Unpause the next call. The current call will change on resume.
						// Assumption: All calls that are not the current are paused.
						nextCall->lSetPaused(false);
					}
					setCurrentCallCore(nextCall);
				}
				bool removed = remove(sharedCall);
			}
			break;
		}
		default: {
		}
	}
}

QVariant CallList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) return QVariant::fromValue(new CallGui(mList[row].objectCast<CallCore>()));
	return QVariant();
}
