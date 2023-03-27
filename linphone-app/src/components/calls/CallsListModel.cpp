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

#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>

#include "app/App.hpp"
#include "components/call/CallModel.hpp"
#include "components/chat-room/ChatRoomInitializer.hpp"
#include "components/conference/ConferenceAddModel.hpp"
#include "components/conference/ConferenceHelperModel.hpp"
#include "components/conference/ConferenceModel.hpp"
#include "components/conferenceInfo/ConferenceInfoModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/participant/ParticipantModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/timeline/TimelineListModel.hpp"
#include "components/timeline/TimelineModel.hpp"
#include "utils/Utils.hpp"

#include "CallsListModel.hpp"



// =============================================================================

using namespace std;

namespace {
// Delay before removing call in ms.
constexpr int DelayBeforeRemoveCall = 6000;
}

static inline int findCallIndex (QList<QSharedPointer<QObject>> &list, const shared_ptr<linphone::Call> &call) {
	auto it = find_if(list.begin(), list.end(), [call](QSharedPointer<QObject> callModel) {
			return call == callModel.objectCast<CallModel>()->getCall();
	});
	return it == list.end() ? -1 : int(distance(list.begin(), it));
}

static inline int findCallIndex (QList<QSharedPointer<QObject>> &list, const CallModel &callModel) {
	return ::findCallIndex(list, callModel.getCall());
}

// -----------------------------------------------------------------------------

CallsListModel::CallsListModel (QObject *parent) : ProxyListModel(parent) {
	mCoreHandlers = CoreManager::getInstance()->getHandlers();
	QObject::connect(
				mCoreHandlers.get(), &CoreHandlers::callStateChanged,
				this, &CallsListModel::handleCallStateChanged
				);
	connect(this, &CallsListModel::countChanged, this, &CallsListModel::canMergeCallsChanged);
}

CallModel *CallsListModel::findCallModelFromPeerAddress (const QString &peerAddress) const {
	std::shared_ptr<linphone::Address> address = Utils::interpretUrl(peerAddress);
	auto it = find_if(mList.begin(), mList.end(), [address](QSharedPointer<QObject> callModel) {
			return callModel.objectCast<CallModel>()->getRemoteAddress()->weakEqual(address);
	});
	return it != mList.end() ? it->objectCast<CallModel>().get() : nullptr;
}

// -----------------------------------------------------------------------------

void CallsListModel::askForTransfer (CallModel *callModel) {
	emit callTransferAsked(callModel);
}

void CallsListModel::askForAttendedTransfer (CallModel *callModel) {
	emit callAttendedTransferAsked(callModel);
}

// -----------------------------------------------------------------------------

void CallsListModel::launchAudioCall (const QString &sipAddress, const QString& prepareTransfertAddress, const QHash<QString, QString> &headers) const {
	CoreManager::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation = true;
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	
	shared_ptr<linphone::Address> address = Utils::interpretUrl(sipAddress);
	if (!address){
		qCritical() << "The calling address is not an interpretable SIP address: " << sipAddress;
		return;
	}
	
	shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
	params->enableVideo(false);
	
	QHashIterator<QString, QString> iterator(headers);
	while (iterator.hasNext()) {
		iterator.next();
		params->addCustomHeader(Utils::appStringToCoreString(iterator.key()), Utils::appStringToCoreString(iterator.value()));
	}
	if(core->getDefaultAccount())
		params->setAccount(core->getDefaultAccount());
	CallModel::setRecordFile(params, Utils::coreStringToAppString(address->getUsername()));
	shared_ptr<linphone::Account> currentAccount = core->getDefaultAccount();
	if(currentAccount){
		if(!CoreManager::getInstance()->getSettingsModel()->getWaitRegistrationForCall() || currentAccount->getState() == linphone::RegistrationState::Ok)
			CallModel::prepareTransfert(core->inviteAddressWithParams(address, params), prepareTransfertAddress);
		else{
			QObject * context = new QObject();
			QObject::connect(CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::registrationStateChanged,context,
							 [address,core,params,currentAccount,prepareTransfertAddress, context](const std::shared_ptr<linphone::Account> &account, linphone::RegistrationState state) mutable {
				if(context && account==currentAccount && state==linphone::RegistrationState::Ok){
					CallModel::prepareTransfert(core->inviteAddressWithParams(address, params), prepareTransfertAddress);
					context->deleteLater();
					context = nullptr;
				}
			});
		}
	}else
		CallModel::prepareTransfert(core->inviteAddressWithParams(address, params), prepareTransfertAddress);
}

void CallsListModel::launchSecureAudioCall (const QString &sipAddress, LinphoneEnums::MediaEncryption encryption, const QHash<QString, QString> &headers, const QString& prepareTransfertAddress) const {
	CoreManager::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation = true;
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	
	shared_ptr<linphone::Address> address = Utils::interpretUrl(sipAddress);
	if (!address)
		return;
	
	shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
	params->enableVideo(false);
	
	QHashIterator<QString, QString> iterator(headers);
	while (iterator.hasNext()) {
		iterator.next();
		params->addCustomHeader(Utils::appStringToCoreString(iterator.key()), Utils::appStringToCoreString(iterator.value()));
	}
	if(core->getDefaultAccount())
		params->setAccount(core->getDefaultAccount());
	CallModel::setRecordFile(params, Utils::coreStringToAppString(address->getUsername()));
	shared_ptr<linphone::Account> currentAccount = core->getDefaultAccount();
	params->setMediaEncryption(LinphoneEnums::toLinphone(encryption));
	if(currentAccount){
		if(!CoreManager::getInstance()->getSettingsModel()->getWaitRegistrationForCall() || currentAccount->getState() == linphone::RegistrationState::Ok)
			CallModel::prepareTransfert(core->inviteAddressWithParams(address, params), prepareTransfertAddress);
		else{
			QObject * context = new QObject();
			QObject::connect(CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::registrationStateChanged,context,
							 [address,core,params,currentAccount,prepareTransfertAddress, context](const std::shared_ptr<linphone::Account> &account, linphone::RegistrationState state) mutable {
				if(context && account==currentAccount && state==linphone::RegistrationState::Ok){
					CallModel::prepareTransfert(core->inviteAddressWithParams(address, params), prepareTransfertAddress);
					context->deleteLater();
					context = nullptr;
				}
			});
		}
	}else
		CallModel::prepareTransfert(core->inviteAddressWithParams(address, params), prepareTransfertAddress);
}

void CallsListModel::launchVideoCall (const QString &sipAddress, const QString& prepareTransfertAddress, const bool& autoSelectAfterCreation, QVariantMap options) const {
	CoreManager::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation = autoSelectAfterCreation;
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	if (!CoreManager::getInstance()->getSettingsModel()->getVideoEnabled()) {
		qWarning() << QStringLiteral("Unable to launch video call. (Video not enabled.) Launching audio call...");
		launchAudioCall(sipAddress, prepareTransfertAddress, {});
		return;
	}
	
	shared_ptr<linphone::Address> address = Utils::interpretUrl(sipAddress);
	if (!address)
		return;
	
	shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
	
	auto layout = options.contains("layout") ? LinphoneEnums::toLinphone((LinphoneEnums::ConferenceLayout)options["layout"].toInt()) : linphone::ConferenceLayout::Grid;
	bool enableMicro =options.contains("micro") ? options["micro"].toBool() : true;
	bool enableVideo = options.contains("video") ? options["video"].toBool() : true;
	bool enableCamera = options.contains("camera") ? options["camera"].toBool() : true;
	bool enableSpeaker = options.contains("audio") ? options["audio"].toBool() : true;

	params->setConferenceVideoLayout(layout);
	params->enableMic(enableMicro);
	params->enableVideo(enableVideo);
	params->setVideoDirection(enableCamera ? linphone::MediaDirection::SendRecv : linphone::MediaDirection::RecvOnly);
	if(core->getDefaultAccount())
		params->setAccount(core->getDefaultAccount());
	CallModel::setRecordFile(params, Utils::coreStringToAppString(address->getUsername()));
	
	auto call = core->inviteAddressWithParams(address, params);
	call->setSpeakerMuted(!enableSpeaker);
	qInfo() << "Launch " << (enableVideo ? "video" : "audio") << " call; camera: " << enableCamera<< " speaker:" << enableSpeaker << ", micro:" << params->micEnabled() << ", layout:" << (int)layout;
	CallModel::prepareTransfert(call, prepareTransfertAddress);
}

QVariantMap CallsListModel::launchChat(const QString &sipAddress, const int& securityLevel) const{
	QVariantList participants;
	participants << sipAddress;
	return createChatRoom("", securityLevel, participants, true);
}

ChatRoomModel* CallsListModel::createChat (const QString &participantAddress) const{
	CoreManager::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation = true;
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Address> address = Utils::interpretUrl(participantAddress);
	if (!address)
		return nullptr;
	
	std::shared_ptr<linphone::ChatRoomParams> params = core->createDefaultChatRoomParams();
	std::list <shared_ptr<linphone::Address> > participants;
	std::shared_ptr<const linphone::Address> localAddress;
	participants.push_back(address);
	
	params->setBackend(linphone::ChatRoomBackend::Basic);
	
	qInfo() << "Create ChatRoom with " <<participantAddress;
	std::shared_ptr<linphone::ChatRoom> chatRoom = core->createChatRoom(params, localAddress, participants);
	
	if( chatRoom != nullptr){
		auto timelineList = CoreManager::getInstance()->getTimelineListModel();
		auto timeline = timelineList->getTimeline(chatRoom, true);
		return timeline->getChatRoomModel();
	}
	return nullptr;
}

ChatRoomModel* CallsListModel::createChat (CallModel * model){
	if(model){
		return model->getChatRoomModel();
	}
	
	return nullptr;
}

bool CallsListModel::createSecureChat (const QString& subject, const QString &participantAddress) const{
	CoreManager::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation = true;
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Address> address = Utils::interpretUrl(participantAddress);
	if (!address)
		return false;
	
	std::shared_ptr<linphone::ChatRoomParams> params = core->createDefaultChatRoomParams();
	std::list <shared_ptr<linphone::Address> > participants;
	std::shared_ptr<const linphone::Address> localAddress;
	participants.push_back(address);
	params->enableEncryption(true);
	
	params->setSubject(Utils::appStringToCoreString(subject));
	params->enableEncryption(true);
	params->enableGroup(true);
	
	qInfo() << "Create secure ChatRoom: " << subject << ", from " << QString::fromStdString(localAddress->asString()) << " and with " <<participantAddress;;
	std::shared_ptr<linphone::ChatRoom> chatRoom = core->createChatRoom(params, localAddress, participants);
// Still needed?
//	if( chatRoom != nullptr){
//		auto timelineList = CoreManager::getInstance()->getTimelineListModel();
//		timelineList->update();
//		auto timeline = timelineList->getTimeline(chatRoom, false);
//		if(!timeline){
//			timeline = timelineList->getTimeline(chatRoom, true);
//			timelineList->add(timeline);
//		}
//		return timeline->getChatRoomModel();
//	}
	return chatRoom != nullptr;
}

// Created, timeline that can be used
QVariantMap CallsListModel::createChatRoom(const QString& subject, const int& securityLevel, const QVariantList& participants, const bool& selectAfterCreation) const{
	return createChatRoom(subject, securityLevel, nullptr, participants, selectAfterCreation);
}

QVariantMap CallsListModel::createChatRoom(const QString& subject, const int& securityLevel, std::shared_ptr<linphone::Address> localAddress, const QVariantList& participants, const bool& selectAfterCreation) const{
	CoreManager::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation = selectAfterCreation;
	QVariantMap result;
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	std::shared_ptr<linphone::ChatRoom> chatRoom;
	QList< std::shared_ptr<linphone::Address>> admins;
	QSharedPointer<TimelineModel> timeline;
	auto timelineList = CoreManager::getInstance()->getTimelineListModel();
	QString localAddressStr = (localAddress ? Utils::coreStringToAppString(localAddress->asStringUriOnly()) : "local");
	qInfo() << "Create ChatRoom: " << subject << " at " << securityLevel << " security, from " << localAddressStr << " and with " << participants;
	
	std::shared_ptr<linphone::ChatRoomParams> params = core->createDefaultChatRoomParams();
	std::list <shared_ptr<linphone::Address> > chatRoomParticipants;
	for(auto p : participants){
		ParticipantModel* participant = p.value<ParticipantModel*>();
		std::shared_ptr<linphone::Address> address;
		if(participant) {
			address = Utils::interpretUrl(participant->getSipAddress());
			if(participant->getAdminStatus())
				admins << address;
		}else{
			QString participant = p.toString();
			if( participant != "")
				address = Utils::interpretUrl(participant);
		}
		if( address)
			chatRoomParticipants.push_back( address );
		else
			qWarning() << "Failed to add participant to conference, bad address : " << (participant ? participant->getSipAddress() : p.toString());
	}
	params->enableEncryption(securityLevel>0);
	
	if( securityLevel<=0)
		params->setBackend(linphone::ChatRoomBackend::Basic);
	params->enableGroup( subject!="" );
	
	
	if(chatRoomParticipants.size() > 0) {
		if(!params->groupEnabled()) {// Chat room is one-one : check if it is already exist with empty or dummy subject
			chatRoom = core->searchChatRoom(params, localAddress
											, nullptr
											, chatRoomParticipants);
			if(chatRoom && ChatRoomModel::isTerminated(chatRoom))
				chatRoom = nullptr;
			params->setSubject(subject != ""?Utils::appStringToCoreString(subject):"Dummy Subject");
			
			if(!chatRoom)
				chatRoom = core->searchChatRoom(params, localAddress
												, nullptr
												, chatRoomParticipants);
				if(chatRoom && ChatRoomModel::isTerminated(chatRoom))
					chatRoom = nullptr;
		}else
			params->setSubject(subject != ""?Utils::appStringToCoreString(subject):"Dummy Subject");
		if( !chatRoom) {
			chatRoom = core->createChatRoom(params, localAddress, chatRoomParticipants);
			if(chatRoom != nullptr && admins.size() > 0){
				auto initializer = ChatRoomInitializer::create(chatRoom);
				initializer->setAdminsData(admins);
				ChatRoomInitializer::start(initializer);
			}
			timeline = timelineList->getTimeline(chatRoom, true);
		}else{
			if(admins.size() > 0){
				ChatRoomInitializer::create(chatRoom)->setAdmins(admins);
			}
			timeline = timelineList->getTimeline(chatRoom, true);
		}
		if(timeline){
			CoreManager::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation = false;
			result["chatRoomModel"] = QVariant::fromValue(timeline->getChatRoomModel());
			if(selectAfterCreation) {// The timeline here will not receive the first creation event. Set Selected if needed
				timeline->delaySelected();
			}
		}
	}
	if( !chatRoom)
		qWarning() << "Chat room cannot be created";
	result["created"] = (chatRoom != nullptr);
	
	return result;
}

void CallsListModel::prepareConferenceCall(ConferenceInfoModel * model){
	if(model->getConferenceInfoState() != LinphoneEnums::ConferenceInfoStateCancelled) {
		auto app = App::getInstance();
		app->smartShowWindow(app->getCallsWindow());
		emit callConferenceAsked(model);
	}
}

int CallsListModel::addAllToConference(){
	return CoreManager::getInstance()->getCore()->addAllToConference();
}

void CallsListModel::mergeAll(){
	auto core = CoreManager::getInstance()->getCore();
	auto currentCalls = CoreManager::getInstance()->getCore()->getCalls();
	shared_ptr<linphone::Conference> conference = core->getConference();
	
	// Search a managable conference from calls
	if(!conference){
		for(auto call : currentCalls){
			auto dbConference = call->getConference();
			if(dbConference && dbConference->getMe()->isAdmin()){
				conference = dbConference;
				break;
			}
		}
	}
  
	auto currentCall = CoreManager::getInstance()->getCore()->getCurrentCall();
	bool enablingVideo = false;
	if( currentCall )
		enablingVideo = currentCall->getCurrentParams()->videoEnabled();
	if(!conference){
		auto parameters = core->createConferenceParams(conference);
		
		if(!CoreManager::getInstance()->getSettingsModel()->getVideoConferenceEnabled()) {
			parameters->enableVideo(false);
			parameters->setConferenceFactoryAddress(nullptr);// Do a local conference
			parameters->setSubject("Local meeting");
		}else{
			parameters->enableVideo(enablingVideo);
			parameters->setSubject("Meeting");
		}
		conference = core->createConferenceWithParams(parameters);
	}
	
	list<shared_ptr<linphone::Address>> allLinphoneAddresses;
	list<shared_ptr<linphone::Address>> newCalls;
	list<shared_ptr<linphone::Call>> runningCallsToAdd;
	
	for(auto call : currentCalls){
		if(!call->getConference()){
			runningCallsToAdd.push_back(call);
		}
	}
 
// 1) Add running calls
	if( runningCallsToAdd.size() > 0){
		conference->addParticipants(runningCallsToAdd);
	}
  /*
// 2) Put in pause and remove all calls that are not in the conference list
	for(const auto &call : CoreManager::getInstance()->getCore()->getCalls()){
      const std::string callAddress = call->getRemoteAddress()->asStringUriOnly();
      auto address = allLinphoneAddresses.begin();
      while(address != allLinphoneAddresses.end() && (*address)->asStringUriOnly() != callAddress)
        ++address;
      if(address == allLinphoneAddresses.end()){// Not in conference list :  put in pause and remove it from conference if it's the case
        if( call->getParams()->getLocalConferenceMode() ){// Remove conference if it is not yet requested
          CoreManager::getInstance()->getCore()->removeFromConference(call);
        }else
          call->pause();
      }
    }*/
}
// -----------------------------------------------------------------------------

int CallsListModel::getRunningCallsNumber () const {
	return CoreManager::getInstance()->getCore()->getCallsNb();
}

bool CallsListModel::canMergeCalls()const{
	auto calls = CoreManager::getInstance()->getCore()->getCalls();
	
	bool mergableConference = false;
	int mergableCalls = 0;
	bool mergable = false;
	for(auto itCall = calls.begin(); !mergable && itCall != calls.end() ; ++itCall ) {
		auto conference = (*itCall)->getConference();
		if(conference){
			if( !mergableConference )
				mergableConference = (conference  && conference->getMe()->isAdmin());
		}else{
			++mergableCalls;
		}
		mergable = (mergableConference && mergableCalls>0)	// A call can be merged into the conference
					 || mergableCalls>1;// 2 calls can be merged
	}
	return mergable;
}

void CallsListModel::terminateAllCalls () const {
	CoreManager::getInstance()->getCore()->terminateAllCalls();
}
void CallsListModel::terminateCall (const QString& sipAddress) const{
	auto coreManager = CoreManager::getInstance();
	shared_ptr<linphone::Address> address = Utils::interpretUrl(sipAddress);
	if (!address)
		qWarning() << "Cannot terminate Call. The address cannot be parsed : " << sipAddress;
	else{
		std::shared_ptr<linphone::Call> call = coreManager->getCore()->getCallByRemoteAddress2(address);
		if( call){
			coreManager->lockVideoRender();
			call->terminate();
			coreManager->unlockVideoRender();
		}else{
			qWarning() << "Cannot terminate call as it doesn't exist : " << sipAddress;
		}
	}
}

std::list<std::shared_ptr<linphone::CallLog>> CallsListModel::getCallHistory(const QString& peerAddress, const QString& localAddress){
	std::shared_ptr<linphone::Address> cleanedPeerAddress = Utils::interpretUrl(Utils::cleanSipAddress(peerAddress));
	std::shared_ptr<linphone::Address> cleanedLocalAddress = Utils::interpretUrl(Utils::cleanSipAddress(localAddress));
	return CoreManager::getInstance()->getCore()->getCallHistory(cleanedPeerAddress, cleanedLocalAddress);
}

// -----------------------------------------------------------------------------

static void joinConference (const shared_ptr<linphone::Call> &call) {
	if (call->getToHeader("method") != "join-conference")
		return;
	
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	if (!core->getConference()) {
		qWarning() << QStringLiteral("Not in a conference. => Responding to `join-conference` as a simple call...");
		return;
	}
	
	shared_ptr<linphone::Conference> conference = core->getConference();
	const QString conferenceId = Utils::coreStringToAppString(call->getToHeader("conference-id"));
	
	if (conference->getId() != Utils::appStringToCoreString(conferenceId)) {
		qWarning() << QStringLiteral("Trying to join conference with an invalid conference id: `%1`. Responding as a simple call...")
					  .arg(conferenceId);
		return;
	}
	qInfo() << QStringLiteral("Join conference: `%1`.").arg(conferenceId);
	
	ConferenceHelperModel helperModel;
	ConferenceHelperModel::ConferenceAddModel *addModel = helperModel.getConferenceAddModel();
	
	CallModel *callModel = &call->getData<CallModel>("call-model");
	callModel->accept();
	addModel->addToConference(call->getRemoteAddress());
	addModel->update();
}

// Global handler on core (is call before call model receive it). Used for model creation.
void CallsListModel::handleCallStateChanged (const shared_ptr<linphone::Call> &call, linphone::Call::State state) {
	switch (state) {
		case linphone::Call::State::IncomingReceived:
			addCall(call);
			joinConference(call);
			break;
			
		case linphone::Call::State::OutgoingInit:
			addCall(call);
			break;
		default:
			break;
	}
}

// Call handler
void CallsListModel::handleCallStatusChanged () {
	auto callModel = qobject_cast<CallModel*>(sender());
	auto call = callModel->getCall();
	if( call){
		auto state = call->getState();
		switch (state) {
			case linphone::Call::State::End:
			case linphone::Call::State::Error:{
				callModel->endCall();
				if(callModel->getCallError() == "")
					removeCall(call);
			} break;
			case linphone::Call::State::Released:
				removeCall(call);
			break;
			
			case linphone::Call::State::StreamsRunning: {
				int index = findCallIndex(mList, call);
				emit callRunning(index, callModel);
			} break;
				
			default:
				break;
		}
	}
}

// -----------------------------------------------------------------------------

void CallsListModel::addCall (const shared_ptr<linphone::Call> &call) {
	int index = findCallIndex(mList, call);
	if( index < 0){
		QSharedPointer<CallModel> callModel = QSharedPointer<CallModel>(new CallModel(call), &QObject::deleteLater);
		qInfo() << QStringLiteral("Add call:") << callModel->getFullLocalAddress() << callModel->getFullPeerAddress();
		App::getInstance()->getEngine()->setObjectOwnership(callModel.get(), QQmlEngine::CppOwnership);
		
		connect(callModel.get(), &CallModel::meAdminChanged, this, &CallsListModel::canMergeCallsChanged);
		connect(callModel.get(), &CallModel::statusChanged, this, &CallsListModel::handleCallStatusChanged);
		
		add(callModel);
		emit layoutChanged();
		
		if (call->getDir() == linphone::Call::Dir::Outgoing) {
			QQuickWindow *callsWindow = App::getInstance()->getCallsWindow();
			if (callsWindow) {
				if (CoreManager::getInstance()->getSettingsModel()->getKeepCallsWindowInBackground()) {
					if (!callsWindow->isVisible())
						callsWindow->showMinimized();
				} else
					App::smartShowWindow(callsWindow);
			}
		}
	}
}


void CallsListModel::addDummyCall () {
	QQuickWindow *callsWindow = App::getInstance()->getCallsWindow();
	if (callsWindow) {
			App::smartShowWindow(callsWindow);
	}
	
	QSharedPointer<CallModel> callModel = QSharedPointer<CallModel>(new CallModel(nullptr), &QObject::deleteLater);
	qInfo() << QStringLiteral("Add call:") << callModel->getFullLocalAddress() << callModel->getFullPeerAddress();
	App::getInstance()->getEngine()->setObjectOwnership(callModel.get(), QQmlEngine::CppOwnership);
	
	// This connection is (only) useful for `CallsListProxyModel`.
	QObject::connect(callModel.get(), &CallModel::isInConferenceChanged, this, [this, callModel](bool) {
		int id = findCallIndex(mList, *callModel);
		emit dataChanged(index(id, 0), index(id, 0));
	});
	connect(callModel.get(), &CallModel::meAdminChanged, this, &CallsListModel::canMergeCallsChanged);
	connect(callModel.get(), &CallModel::statusChanged, this, &CallsListModel::handleCallStatusChanged);
	
	add(callModel);
	emit layoutChanged();
}

void CallsListModel::removeCall (const shared_ptr<linphone::Call> &call) {
	CallModel *callModel = nullptr;
	
	if(!call->dataExists("call-model"))
		return;
	callModel = &call->getData<CallModel>("call-model");
	if( callModel && callModel->getCallError() != ""){	// Wait some time to display an error on ending call.
		QTimer::singleShot( DelayBeforeRemoveCall , this, [this, callModel] {
				removeCallCb(callModel);
		});
	}else{
		remove(callModel);
	}
}

void CallsListModel::removeCallCb (CallModel *callModel) {
	callModel->removeCall();
	remove(callModel);
}
