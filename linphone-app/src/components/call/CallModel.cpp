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
#include "CallModel.hpp"

#include <QDateTime>
#include <QQuickWindow>
#include <QRegularExpression>
#include <QTimer>

#include "app/App.hpp"
#include "components/calls/CallsListModel.hpp"
#include "components/chat-room/ChatRoomModel.hpp"
#include "components/conference/ConferenceModel.hpp"
#include "components/conferenceInfo/ConferenceInfoModel.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/timeline/TimelineListModel.hpp"
#include "utils/MediastreamerUtils.hpp"
#include "utils/Utils.hpp"

#include "linphone/api/c-search-result.h"

// =============================================================================

using namespace std;

namespace {
constexpr char AutoAnswerObjectName[] = "auto-answer-timer";
}

CallModel::CallModel (shared_ptr<linphone::Call> call){
	CoreManager *coreManager = CoreManager::getInstance();
	SettingsModel *settings = coreManager->getSettingsModel();
	
	connect(this, &CallModel::callIdChanged, this, &CallModel::chatRoomModelChanged);// When the call Id change, the chat room change.
	mCall = call;
	if(mCall)
		mCall->setData("call-model", *this);
	updateIsInConference();
	if(mCall) {
		mConferenceVideoLayout = LinphoneEnums::fromLinphone(mCall->getParams()->getConferenceVideoLayout());
		if(mCall->getConference()){
			if( mConferenceVideoLayout == LinphoneEnums::ConferenceLayoutGrid)
				settings->setCameraMode(settings->getGridCameraMode());
			else
				settings->setCameraMode(settings->getActiveSpeakerCameraMode());
		}else
			settings->setCameraMode(settings->getCallCameraMode());
	}
	
	// Deal with auto-answer.
	if (!isOutgoing()) {
		
		
		if (settings->getAutoAnswerStatus()) {
			QTimer *timer = new QTimer(this);
			timer->setInterval(settings->getAutoAnswerDelay());
			timer->setSingleShot(true);
			timer->setObjectName(AutoAnswerObjectName);
			
			QObject::connect(timer, &QTimer::timeout, this, &CallModel::acceptWithAutoAnswerDelay);
			timer->start();
		}
	}
	
	CoreHandlers *coreHandlers = coreManager->getHandlers().get();
	QObject::connect(coreHandlers, &CoreHandlers::callStateChanged, this, &CallModel::handleCallStateChanged );
	QObject::connect(coreHandlers, &CoreHandlers::callEncryptionChanged, this, &CallModel::handleCallEncryptionChanged );
	
	// Update fields and make a search to know to who the call belong
	mMagicSearch = CoreManager::getInstance()->getCore()->createMagicSearch();
	mSearch = std::make_shared<SearchListener>(this);
	QObject::connect(mSearch.get(), SIGNAL(searchReceived(std::list<std::shared_ptr<linphone::SearchResult>> )), this, SLOT(searchReceived(std::list<std::shared_ptr<linphone::SearchResult>>)));
	mMagicSearch->addListener(mSearch);

	if(mCall) {
		mRemoteAddress = mCall->getRemoteAddress()->clone();
		if(mCall->getConference())
			mConferenceModel = ConferenceModel::create(mCall->getConference());
		auto conferenceInfo = CoreManager::getInstance()->getCore()->findConferenceInformationFromUri(getConferenceAddress());
		if(	conferenceInfo ){
			mConferenceInfoModel = ConferenceInfoModel::create(conferenceInfo);
		}
		mMagicSearch->getContactsListAsync(mRemoteAddress->getUsername(),mRemoteAddress->getDomain(), (int)linphone::MagicSearchSource::LdapServers | (int)linphone::MagicSearchSource::Friends, linphone::MagicSearchAggregation::Friend);
	}
}

CallModel::~CallModel () {
	mMagicSearch->removeListener(mSearch);
	if(mCall)
		mCall->unsetData("call-model");
}

// -----------------------------------------------------------------------------

QString CallModel::getPeerAddress () const {
	return Utils::coreStringToAppString(mRemoteAddress->asStringUriOnly());
}

QString CallModel::getLocalAddress () const {
	return mCall ? Utils::coreStringToAppString(mCall->getCallLog()->getLocalAddress()->asStringUriOnly()) : "";
}

QString CallModel::getFullPeerAddress () const {
	return Utils::coreStringToAppString(mRemoteAddress->asString());
}

QString CallModel::getFullLocalAddress () const {
	return mCall ? Utils::coreStringToAppString(mCall->getCallLog()->getLocalAddress()->asString()) : "";
}

std::shared_ptr<linphone::Address> CallModel::getConferenceAddress () const{
	std::shared_ptr<linphone::Address> conferenceAddress;
	if(mCall){
		auto remoteContact = mCall->getRemoteContact();
		
		if (mCall->getDir() == linphone::Call::Dir::Incoming){
			if( remoteContact != "" )
				conferenceAddress = CoreManager::getInstance()->getCore()->interpretUrl(remoteContact);
		}else
			conferenceAddress = mCall->getRemoteAddress()->clone();
	}	
	return conferenceAddress;
}
// -----------------------------------------------------------------------------

ContactModel *CallModel::getContactModel() const{
	QString cleanedAddress = mCall ? Utils::cleanSipAddress(Utils::coreStringToAppString(mCall->getRemoteAddress()->asString())) : "";
	return CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(cleanedAddress).get();
}

ChatRoomModel * CallModel::getChatRoomModel() const{
	if(mCall && mCall->getCallLog()->getCallId() != "") {
		auto currentParams = mCall->getCurrentParams();
		bool isEncrypted = currentParams->getMediaEncryption() != linphone::MediaEncryption::None;
		SettingsModel * settingsModel = CoreManager::getInstance()->getSettingsModel();
		
		if( mCall->getChatRoom() && (settingsModel->getSecureChatEnabled() && 
			(!settingsModel->getStandardChatEnabled() || (settingsModel->getStandardChatEnabled() && isEncrypted))
			)){
			std::shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
			std::shared_ptr<const linphone::ChatRoomParams> dbParams = mCall->getChatRoom()->getCurrentParams();
			std::shared_ptr<linphone::ChatRoomParams> params = core->createDefaultChatRoomParams();
			auto callLog = mCall->getCallLog();
			auto callLocalAddress = callLog->getLocalAddress();
			std::list<std::shared_ptr<linphone::Address>> participants;
			std::shared_ptr<linphone::ChatRoom> chatRoom;
// Copy parameters			
			params->setBackend(dbParams->getBackend());
			params->setEncryptionBackend(dbParams->getEncryptionBackend());
			params->enableEncryption(dbParams->encryptionEnabled());
			params->enableGroup(dbParams->groupEnabled());
			params->enableRtt(dbParams->rttEnabled());
			params->setSubject(dbParams->getSubject());
			params->enableEncryption(true);
			std::list<std::shared_ptr<linphone::Participant>> chatRoomParticipants = mCall->getChatRoom()->getParticipants();
			for(auto p : chatRoomParticipants){
				participants.push_back(p->getAddress()->clone());
			}
			chatRoom = core->searchChatRoom(params, callLocalAddress
											 , nullptr
											 , participants);
			if(chatRoom)
				return CoreManager::getInstance()->getTimelineListModel()->getChatRoomModel(chatRoom, true).get();
		}
		return CoreManager::getInstance()->getTimelineListModel()->getChatRoomModel(mCall->getChatRoom(), true).get();
	}else
		return nullptr;
}

ConferenceModel * CallModel::getConferenceModel(){
	return mConferenceModel.get();
}

ConferenceInfoModel * CallModel::getConferenceInfoModel(){
	return mConferenceInfoModel.get();
}

QSharedPointer<ConferenceModel> CallModel::getConferenceSharedModel(){
	if(mCall->getConference() && !mConferenceModel){
		mConferenceModel = ConferenceModel::create(mCall->getConference());	
		emit conferenceModelChanged();
	}
	return mConferenceModel;
}

bool CallModel::isConference () const{
	return mCall->getConference() != nullptr;
}

// -----------------------------------------------------------------------------
void CallModel::setRecordFile (const shared_ptr<linphone::CallParams> &callParams) {
	callParams->setRecordFile(Utils::appStringToCoreString(
								  CoreManager::getInstance()->getSettingsModel()->getSavedCallsFolder()
								  .append(generateSavedFilename())
								  .append(".mkv")
								  ));
}

void CallModel::setRecordFile (const shared_ptr<linphone::CallParams> &callParams, const QString &to) {
	const QString from(
				Utils::coreStringToAppString(
					CoreManager::getInstance()->getAccountSettingsModel()->getUsedSipAddress()->getUsername()
					)
				);
	
	callParams->setRecordFile(Utils::appStringToCoreString(
								  CoreManager::getInstance()->getSettingsModel()->getSavedCallsFolder()
								  .append(generateSavedFilename(from, to))
								  .append(".mkv")
								  ));
}

// -----------------------------------------------------------------------------

void CallModel::updateStats (const shared_ptr<const linphone::CallStats> &callStats) {
	switch (callStats->getType()) {
		case linphone::StreamType::Text:
		case linphone::StreamType::Unknown:
			break;
			
		case linphone::StreamType::Audio:
			updateStats(callStats, mAudioStats);
			break;
		case linphone::StreamType::Video:
			updateStats(callStats, mVideoStats);
			break;
	}
	
	emit statsUpdated();
}

// -----------------------------------------------------------------------------

float CallModel::getSpeakerVolumeGain () const {
	float gain = mCall ? mCall->getSpeakerVolumeGain() : 0;
	if( gain < 0)
		gain = CoreManager::getInstance()->getSettingsModel()->getPlaybackGain();
	return gain;
}

void CallModel::setSpeakerVolumeGain (float volume) {
	Q_ASSERT(volume >= 0.0f && volume <= 1.0f);
	float oldGain = getSpeakerVolumeGain();
	if( mCall && mCall->getSpeakerVolumeGain() >= 0)
		mCall->setSpeakerVolumeGain(volume);
	else
		CoreManager::getInstance()->getSettingsModel()->setPlaybackGain(volume);
	if( (int)(oldGain * 1000) != (int)(volume*1000))
	emit speakerVolumeGainChanged(getSpeakerVolumeGain());
}

float CallModel::getMicroVolumeGain () const {
	float gain = mCall ? mCall->getMicrophoneVolumeGain() : 0.0;
	if( gain < 0)
		gain = CoreManager::getInstance()->getSettingsModel()->getCaptureGain();
	return gain;
}

void CallModel::setMicroVolumeGain (float volume) {
	Q_ASSERT(volume >= 0.0f && volume <= 1.0f);
	float oldGain = getMicroVolumeGain();
	if(mCall && mCall->getMicrophoneVolumeGain() >= 0)
		mCall->setMicrophoneVolumeGain(volume);
	else
		CoreManager::getInstance()->getSettingsModel()->setCaptureGain(volume);
	if( (int)(oldGain * 1000) != (int)(volume*1000))
		emit microVolumeGainChanged(getMicroVolumeGain());
}

// -----------------------------------------------------------------------------

void CallModel::notifyCameraFirstFrameReceived (unsigned int width, unsigned int height) {
	if (mNotifyCameraFirstFrameReceived) {
		mNotifyCameraFirstFrameReceived = false;
		emit cameraFirstFrameReceived(width, height);
	}
}

// -----------------------------------------------------------------------------

void CallModel::accept () {
	accept(false);
}

void CallModel::acceptWithVideo () {
	accept(true);
}

void CallModel::terminate () {
	CoreManager *core = CoreManager::getInstance();
	core->lockVideoRender();
	if(mCall)
		mCall->terminate();
	core->unlockVideoRender();
}

// -----------------------------------------------------------------------------

void CallModel::askForTransfer () {
	CoreManager::getInstance()->getCallsListModel()->askForTransfer(this);
}

void CallModel::askForAttendedTransfer () {
	CoreManager::getInstance()->getCallsListModel()->askForAttendedTransfer(this);
}

bool CallModel::transferTo (const QString &sipAddress) {
	bool failure = mCall ? !!mCall->transferTo(Utils::interpretUrl(sipAddress)) : false;
	if (failure)
		qWarning() << QStringLiteral("Unable to transfer: `%1`.").arg(sipAddress);
	return !failure;
}

bool CallModel::transferToAnother (const QString &peerAddress) {
	qInfo() << QStringLiteral("Transferring to another: `%1`.").arg(peerAddress);
	CallModel *transferCallModel = CoreManager::getInstance()->getCallsListModel()->findCallModelFromPeerAddress(peerAddress);
	if (transferCallModel == nullptr) {
		qWarning() << QStringLiteral("Unable to transfer to another: `%1` (peer not found)").arg(peerAddress);
		return false;
	}
	bool failure = mCall ? !!transferCallModel->mCall->transferToAnother(mCall) : false;
	if (failure)
		qWarning() << QStringLiteral("Unable to transfer to another: `%1` (transfer failed)").arg(peerAddress);
	return !failure;
}
// -----------------------------------------------------------------------------

void CallModel::acceptVideoRequest () {
	if(mCall) {
		shared_ptr<linphone::CallParams> params = CoreManager::getInstance()->getCore()->createCallParams(mCall);
		params->enableVideo(true);
		mCall->acceptUpdate(params);
	}
}

void CallModel::rejectVideoRequest () {
	if(mCall) {
		shared_ptr<linphone::CallParams> params = CoreManager::getInstance()->getCore()->createCallParams(mCall);
		params->enableVideo(false);
	
		mCall->acceptUpdate(params);
	}
}

void CallModel::takeSnapshot () {
	static QString oldName;
	QString newName(generateSavedFilename().append(".jpg"));
	
	if (newName == oldName) {
		qWarning() << QStringLiteral("Unable to take snapshot. Wait one second.");
		return;
	}
	oldName = newName;
	
	qInfo() << QStringLiteral("Take snapshot of call:") << this;
	
	const QString filePath(CoreManager::getInstance()->getSettingsModel()->getSavedScreenshotsFolder().append(newName));
	if(mCall)
		mCall->takeVideoSnapshot(Utils::appStringToCoreString(filePath));
	App::getInstance()->getNotifier()->notifySnapshotWasTaken(filePath);
}

void CallModel::startRecording () {
	if (mRecording)
		return;
	
	qInfo() << QStringLiteral("Start recording call:") << this;
	if(mCall)
		mCall->startRecording();
	mRecording = true;
	
	emit recordingChanged(true);
}

void CallModel::stopRecording () {
	if (!mRecording)
		return;
	
	qInfo() << QStringLiteral("Stop recording call:") << this;
	
	mRecording = false;
	if(mCall) {
		mCall->stopRecording();
	
		App::getInstance()->getNotifier()->notifyRecordingCompleted(
				Utils::coreStringToAppString(mCall->getParams()->getRecordFile())
				);
	}
	emit recordingChanged(false);
}

// -----------------------------------------------------------------------------

void CallModel::handleCallEncryptionChanged (const shared_ptr<linphone::Call> &call) {
	if (call == mCall)
		emit securityUpdated();
}

void CallModel::handleCallStateChanged (const shared_ptr<linphone::Call> &call, linphone::Call::State state) {
	if (call != mCall)
		return;
	
	updateIsInConference();
	if(!mConferenceInfoModel){// Check if conferenceInfo has been set.
		auto conferenceInfo = CoreManager::getInstance()->getCore()->findConferenceInformationFromUri(getConferenceAddress());
		if(	conferenceInfo ){
				mConferenceInfoModel = ConferenceInfoModel::create(conferenceInfo);
				emit conferenceInfoModelChanged();
		}
	}
	switch (state) {
		case linphone::Call::State::Error:
		case linphone::Call::State::End:
			setCallErrorFromReason(call->getReason());
			stopAutoAnswerTimer();
			stopRecording();
			mPausedByRemote = false;
			break;
			
		case linphone::Call::State::StreamsRunning: {
			if (!mWasConnected && CoreManager::getInstance()->getSettingsModel()->getAutomaticallyRecordCalls()) {
				startRecording();
				mWasConnected = true;
			}
			mPausedByRemote = false;
			setConferenceVideoLayout(LinphoneEnums::fromLinphone(call->getParams()->getConferenceVideoLayout()));
			setCallId(QString::fromStdString(mCall->getCallLog()->getCallId()));
			break;
		}
		case linphone::Call::State::Connected:
		case linphone::Call::State::Referred:
		case linphone::Call::State::Released:
			mPausedByRemote = false;
			break;
			
		case linphone::Call::State::PausedByRemote:
			mNotifyCameraFirstFrameReceived = true;
			mPausedByRemote = true;
			break;
			
		case linphone::Call::State::Pausing:
			mNotifyCameraFirstFrameReceived = true;
			mPausedByUser = true;
			break;
			
		case linphone::Call::State::Resuming:
			mPausedByUser = false;
			break;
			
		case linphone::Call::State::UpdatedByRemote:
			qDebug() << "UpdatedByRemote : " << (mCall ? QString( "Video enabled ? CurrentParams:") + mCall->getCurrentParams()->videoEnabled() + QString(", RemoteParams:")+mCall->getRemoteParams()->videoEnabled() : " call NULL");
			if (mCall && !mCall->getCurrentParams()->videoEnabled() && mCall->getRemoteParams()->videoEnabled()) {
				mCall->deferUpdate();
				emit videoRequested();
			}
			break;
			
		case linphone::Call::State::Idle:
		case linphone::Call::State::IncomingReceived:
		case linphone::Call::State::OutgoingInit:
		case linphone::Call::State::OutgoingProgress:
		case linphone::Call::State::OutgoingRinging:
		case linphone::Call::State::OutgoingEarlyMedia:
		case linphone::Call::State::Paused:
		case linphone::Call::State::IncomingEarlyMedia:
		case linphone::Call::State::Updating:
		case linphone::Call::State::EarlyUpdatedByRemote:
		case linphone::Call::State::EarlyUpdating:
		case linphone::Call::State::PushIncomingReceived:
			break;
	}
	
	emit statusChanged(getStatus());
}

// -----------------------------------------------------------------------------

void CallModel::accept (bool withVideo) {
	stopAutoAnswerTimer();
	CoreManager *coreManager = CoreManager::getInstance();
	
	QQuickWindow *callsWindow = App::getInstance()->getCallsWindow();
	if (callsWindow) {
		if (coreManager->getSettingsModel()->getKeepCallsWindowInBackground()) {
			if (!callsWindow->isVisible())
				callsWindow->showMinimized();
		} else
			App::smartShowWindow(callsWindow);
	}
	qApp->processEvents();  // Process GUI events before accepting in order to be synchronized with Call objects and be ready to get SDK events
	shared_ptr<linphone::Core> core = coreManager->getCore();
	if(mCall) {
		shared_ptr<linphone::CallParams> params = core->createCallParams(mCall);
		params->enableVideo(withVideo);
		setRecordFile(params);
		auto localAddress = mCall->getCallLog()->getLocalAddress();
		for(auto account : core->getAccountList()){
			if( account->getParams()->getIdentityAddress()->weakEqual(localAddress)){
				params->setAccount(account);
				break;
			}
		}
		
		mCall->acceptWithParams(params);
	}
}

// -----------------------------------------------------------------------------

void CallModel::updateIsInConference () {
	if (mIsInConference != (mCall &&  mCall->getCurrentParams()->getLocalConferenceMode() )) {
		mIsInConference = !mIsInConference;
	}
	emit isInConferenceChanged(mIsInConference);
}

// -----------------------------------------------------------------------------

void CallModel::stopAutoAnswerTimer () const {
	QTimer *timer = findChild<QTimer *>(AutoAnswerObjectName, Qt::FindDirectChildrenOnly);
	if (timer) {
		timer->stop();
		timer->deleteLater();
	}
}

// -----------------------------------------------------------------------------

CallModel::CallStatus CallModel::getStatus () const {
	if(mCall){
		switch (mCall->getState()) {
			case linphone::Call::State::Connected:
			case linphone::Call::State::StreamsRunning:
				return CallStatusConnected;
				
			case linphone::Call::State::End:
			case linphone::Call::State::Error:
			case linphone::Call::State::Referred:
			case linphone::Call::State::Released:
				return CallStatusEnded;
				
			case linphone::Call::State::Paused:
			case linphone::Call::State::PausedByRemote:
			case linphone::Call::State::Pausing:
			case linphone::Call::State::Resuming:
				return CallStatusPaused;
				
			case linphone::Call::State::Updating:
			case linphone::Call::State::UpdatedByRemote:
				return mPausedByRemote ? CallStatusPaused : CallStatusConnected;
				
			case linphone::Call::State::EarlyUpdatedByRemote:
			case linphone::Call::State::EarlyUpdating:
			case linphone::Call::State::Idle:
			case linphone::Call::State::IncomingEarlyMedia:
			case linphone::Call::State::IncomingReceived:
			case linphone::Call::State::OutgoingEarlyMedia:
			case linphone::Call::State::OutgoingInit:
			case linphone::Call::State::OutgoingProgress:
			case linphone::Call::State::OutgoingRinging:
				break;
		}
		
		return mCall->getDir() == linphone::Call::Dir::Incoming ? CallStatusIncoming : CallStatusOutgoing;
	}else
		return CallStatusIdle;
}

// -----------------------------------------------------------------------------

void CallModel::acceptWithAutoAnswerDelay () {
	CoreManager *coreManager = CoreManager::getInstance();
	SettingsModel *settingsModel = coreManager->getSettingsModel();
	
	// Use auto-answer if activated and it's the only call.
	if (settingsModel->getAutoAnswerStatus() && coreManager->getCore()->getCallsNb() == 1) {
		if (mCall && mCall->getRemoteParams()->videoEnabled() && settingsModel->getAutoAnswerVideoStatus() && settingsModel->getVideoSupported())
			acceptWithVideo();
		else
			accept();
	}
}

// -----------------------------------------------------------------------------

QString CallModel::getCallError () const {
	return mCallError;
}

void CallModel::setCallErrorFromReason (linphone::Reason reason) {
	switch (reason) {
		case linphone::Reason::Declined:
			mCallError = tr("callErrorDeclined");
			break;
		case linphone::Reason::NotFound:
			mCallError = tr("callErrorNotFound");
			break;
		case linphone::Reason::Busy:
			mCallError = tr("callErrorBusy");
			break;
		case linphone::Reason::NotAcceptable:
			mCallError = tr("callErrorNotAcceptable");
			break;
		default:
			break;
	}
	
	if (!mCallError.isEmpty())
		qInfo() << QStringLiteral("Call terminated with error (%1):").arg(mCallError) << this;
	
	emit callErrorChanged(mCallError);
}

void CallModel::setCallId(const QString& callId){
	if(callId != mCallId){
		mCallId = callId;
		emit callIdChanged();
	}
}

// -----------------------------------------------------------------------------

int CallModel::getDuration () const {
	return mCall ? mCall->getDuration() : 0;
}

float CallModel::getQuality () const {
	return mCall ? mCall->getCurrentQuality() : 0.0;
}

// -----------------------------------------------------------------------------

float CallModel::getSpeakerVu () const {
	if (mCall && mCall->getState() == linphone::Call::State::StreamsRunning)
		return MediastreamerUtils::computeVu(mCall->getPlayVolume());
	return 0.0;
}

float CallModel::getMicroVu () const {
	if (mCall && mCall->getState() == linphone::Call::State::StreamsRunning)
		return MediastreamerUtils::computeVu(mCall->getRecordVolume());
	return 0.0;
}

// -----------------------------------------------------------------------------

bool CallModel::getSpeakerMuted () const {
	return mCall && mCall->getSpeakerMuted();
}

void CallModel::setSpeakerMuted (bool status) {
	if (status == getSpeakerMuted())
		return;
	if(mCall)
		mCall->setSpeakerMuted(status);
	emit speakerMutedChanged(getSpeakerMuted());
}

// -----------------------------------------------------------------------------

bool CallModel::getMicroMuted () const {
	return mCall && mCall->getMicrophoneMuted();
}

void CallModel::setMicroMuted (bool status) {
	if (status == getMicroMuted())
		return;
	if(mCall)
		mCall->setMicrophoneMuted(status);
	emit microMutedChanged(getMicroMuted());
}

// -----------------------------------------------------------------------------

bool CallModel::getCameraEnabled () const{
	return mCall && (((int)mCall->getCurrentParams()->getVideoDirection() & (int)linphone::MediaDirection::SendOnly) == (int)linphone::MediaDirection::SendOnly);
}

void CallModel::setCameraEnabled (bool status){
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	if (!core->videoSupported()) {
		qWarning() << QStringLiteral("Unable to update video call property. (Video not supported.)");
		return;
	}
	if(mCall) {
		switch (mCall->getState()) {
			case linphone::Call::State::Connected:
			case linphone::Call::State::StreamsRunning:
				break;
			default: {
				qWarning() << "Cannot set Camera mode because of call status : " << (int)mCall->getState() << " is not in {" <<(int)linphone::Call::State::Connected << ", " <<(int)linphone::Call::State::StreamsRunning << "}";
				return;
			}
		}
		if (status == getCameraEnabled())
			return;

		shared_ptr<linphone::CallParams> params = core->createCallParams(mCall);
		params->setVideoDirection(status ? linphone::MediaDirection::SendRecv : linphone::MediaDirection::RecvOnly);
		params->enableVideo(true);
		mCall->update(params);
	}
}
// -----------------------------------------------------------------------------

bool CallModel::getPausedByUser () const {
	return mPausedByUser;
}

void CallModel::setPausedByUser (bool status) {
	if(mCall){
		switch (mCall->getState()) {
			case linphone::Call::State::Connected:
			case linphone::Call::State::StreamsRunning:
			case linphone::Call::State::Paused:
			case linphone::Call::State::PausedByRemote:
				break;
			default: return;
		}
		
		if (status) {
			if (!mPausedByUser)
				mCall->pause();
			return;
		}
		
		if (mPausedByUser)
			mCall->resume();
	}
}

// -----------------------------------------------------------------------------
bool CallModel::getRemoteVideoEnabled () const {
	shared_ptr<const linphone::CallParams> params = mCall->getRemoteParams();
	return params && params->videoEnabled();
}

bool CallModel::getVideoEnabled () const {
	if(mCall){
		shared_ptr<const linphone::CallParams> params = mCall->getCurrentParams();
		return params && params->videoEnabled();
	}else
		return true;
}

void CallModel::setVideoEnabled (bool status) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	if (!core->videoSupported()) {
		qWarning() << QStringLiteral("Unable to update video call property. (Video not supported.)");
		return;
	}
	if(mCall) {
		switch (mCall->getState()) {
			case linphone::Call::State::Connected:
			case linphone::Call::State::StreamsRunning:
				break;
			default: {
				qWarning() << "Cannot set Video mode because of call status : " << (int)mCall->getState() << " is not in {" <<(int)linphone::Call::State::Connected << ", " <<(int)linphone::Call::State::StreamsRunning << "}"; 
				return;
			}
		}
		
		if (status == getVideoEnabled())
			return;
		
		shared_ptr<linphone::CallParams> params = core->createCallParams(mCall);
		params->enableVideo(status);
		
		mCall->update(params);
	}
}

// -----------------------------------------------------------------------------

bool CallModel::getUpdating () const {
	if(mCall) {
		switch (mCall->getState()) {
			case linphone::Call::State::Connected:
			case linphone::Call::State::StreamsRunning:
			case linphone::Call::State::Paused:
			case linphone::Call::State::PausedByRemote:
				return false;
				
			default:
				break;
		}
	}
	
	return true;
}

bool CallModel::getRecording () const {
	return mRecording;
}

bool CallModel::getSnapshotEnabled() const{
	return getVideoEnabled() &&  getConferenceVideoLayout() != LinphoneEnums::ConferenceLayout::ConferenceLayoutGrid;
}

// -----------------------------------------------------------------------------

void CallModel::sendDtmf (const QString &dtmf) {
	const char key = dtmf.constData()[0].toLatin1();
	qInfo() << QStringLiteral("Send dtmf: `%1`.").arg(key);
	if(mCall)
		mCall->sendDtmf(key);
	CoreManager::getInstance()->getCore()->playDtmf(key, DtmfSoundDelay);
}

// -----------------------------------------------------------------------------

void CallModel::verifyAuthenticationToken (bool verify) {
	if(mCall)
		mCall->setAuthenticationTokenVerified(verify);
	emit securityUpdated();
}

// -----------------------------------------------------------------------------

void CallModel::updateStreams () {
	if(mCall)
		mCall->update(nullptr);
}
void CallModel::toggleSpeakerMute(){
	setSpeakerMuted(!getSpeakerMuted());
}

// -----------------------------------------------------------------------------

// Set remote display name when a search has been done
// Local Friend > LDAP friend > Address > others
void CallModel::searchReceived(std::list<std::shared_ptr<linphone::SearchResult>> results){
	bool found = false;
	for(auto it = results.begin() ; it != results.end() && !found ; ++it){
		if((*it)->getFriend()){// Local Friend
			if((*it)->getFriend()->getAddress()->weakEqual(mRemoteAddress)){
				setRemoteDisplayName((*it)->getFriend()->getName());
				found = true;
			}
		}else{
			if((*it)->getAddress()->weakEqual(mRemoteAddress)){
				std::string newDisplayName = (*it)->getAddress()->getDisplayName();
				if(!newDisplayName.empty()){
				// LDAP friend
					if( ((*it)->getSourceFlags() & (int) linphone::MagicSearchSource::LdapServers) == (int) linphone::MagicSearchSource::LdapServers){
						setRemoteDisplayName(newDisplayName);
						found = true;
					}else if( Utils::coreStringToAppString(mRemoteAddress->getDisplayName()).isEmpty()){
						setRemoteDisplayName(newDisplayName);	
						found = true;
					}
				}
			}
		}
	}
}

void CallModel::callEnded(){
	if(mCall){
		ChatRoomModel * model = getChatRoomModel();
		
		if(model){
			model->callEnded(mCall);
		}else{// No chat rooms have been associated for this call. Search one in current chat room list
			shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
			std::shared_ptr<linphone::ChatRoomParams> params = core->createDefaultChatRoomParams();
			std::list<std::shared_ptr<linphone::Address>> participants;
			
			auto chatRoom = core->searchChatRoom(params, mCall->getCallLog()->getLocalAddress()
												 , mCall->getRemoteAddress()
												 , participants);
			QSharedPointer<ChatRoomModel> chatRoomModel= CoreManager::getInstance()->getTimelineListModel()->getChatRoomModel(chatRoom, false);
			if(chatRoomModel)
				chatRoomModel->callEnded(mCall);
		}
	}
}

void CallModel::setRemoteDisplayName(const std::string& name){
	mRemoteAddress->setDisplayName(name);
	if(mCall) {
		auto callLog = mCall->getCallLog();
		if(name!= "") {
			auto core = CoreManager::getInstance()->getCore();
			auto address = Utils::interpretUrl(getFullPeerAddress());
			callLog->setRemoteAddress(address);
		}
	}
	emit fullPeerAddressChanged();
	ChatRoomModel * model = getChatRoomModel();
	if(model)
		model->emitFullPeerAddressChanged();
}

QString CallModel::getTransferAddress () const {
	return mTransferAddress;
}

void CallModel::setTransferAddress (const QString &transferAddress) {
	mTransferAddress = transferAddress;
	emit transferAddressChanged(mTransferAddress);
}

void CallModel::prepareTransfert(shared_ptr<linphone::Call> call, const QString& transfertAddress){
	if( call && transfertAddress != ""){
		CallModel * model = &call->getData<CallModel>("call-model");
		model->setTransferAddress(transfertAddress);
	}
}

std::shared_ptr<linphone::Address> CallModel::getRemoteAddress()const{
	return mRemoteAddress;
}

LinphoneEnums::ConferenceLayout CallModel::getConferenceVideoLayout() const{
	return LinphoneEnums::fromLinphone(mCall->getParams()->getConferenceVideoLayout());
}

void CallModel::changeConferenceVideoLayout(LinphoneEnums::ConferenceLayout layout){
	auto coreManager = CoreManager::getInstance();
	if( layout == LinphoneEnums::ConferenceLayoutGrid)
		coreManager->getSettingsModel()->setCameraMode(coreManager->getSettingsModel()->getGridCameraMode());
	else
		coreManager->getSettingsModel()->setCameraMode(coreManager->getSettingsModel()->getActiveSpeakerCameraMode());
	shared_ptr<linphone::CallParams> params = coreManager->getCore()->createCallParams(mCall);
	params->setConferenceVideoLayout(LinphoneEnums::toLinphone(layout));
	params->enableVideo(true);
	mCall->update(params);
}

void CallModel::setConferenceVideoLayout(LinphoneEnums::ConferenceLayout layout){
	auto settings = CoreManager::getInstance()->getSettingsModel();
	if(mCall->getConference()){
			if( layout == LinphoneEnums::ConferenceLayoutGrid)
				settings->setCameraMode(settings->getGridCameraMode());
			else
				settings->setCameraMode(settings->getActiveSpeakerCameraMode());
		}else
			settings->setCameraMode(settings->getCallCameraMode());
	if( mConferenceVideoLayout != layout){
		mConferenceVideoLayout = layout;
		emit conferenceVideoLayoutChanged();
		emit snapshotEnabledChanged();
	}
}

// -----------------------------------------------------------------------------

CallModel::CallEncryption CallModel::getEncryption () const {
	if(mCall)
		return static_cast<CallEncryption>(mCall->getCurrentParams()->getMediaEncryption());
	else
		return CallEncryptionNone;
}

bool CallModel::isSecured () const {
	if(mCall){
		shared_ptr<const linphone::CallParams> params = mCall->getCurrentParams();
		linphone::MediaEncryption encryption = params->getMediaEncryption();
		return (
					encryption == linphone::MediaEncryption::ZRTP && mCall->getAuthenticationTokenVerified()
					) || encryption == linphone::MediaEncryption::SRTP || encryption == linphone::MediaEncryption::DTLS;
	}else
		return false;
}


// -----------------------------------------------------------------------------

QString CallModel::getLocalSas () const {
	if(mCall){
		QString token = Utils::coreStringToAppString(mCall->getAuthenticationToken());
		return mCall->getDir() == linphone::Call::Dir::Incoming ? token.left(2).toUpper() : token.right(2).toUpper();
	}else
		return "";
}

QString CallModel::getRemoteSas () const {
	if(mCall){
		QString token = Utils::coreStringToAppString(mCall->getAuthenticationToken());
		return mCall->getDir() != linphone::Call::Dir::Incoming ? token.left(2).toUpper() : token.right(2).toUpper();
	}else
		return "";
}

// -----------------------------------------------------------------------------

QString CallModel::getSecuredString () const {
	if(mCall){
		switch (mCall->getCurrentParams()->getMediaEncryption()) {
			case linphone::MediaEncryption::SRTP:
				return QStringLiteral("SRTP");
			case linphone::MediaEncryption::ZRTP:
				return QStringLiteral("ZRTP");
			case linphone::MediaEncryption::DTLS:
				return QStringLiteral("DTLS");
			case linphone::MediaEncryption::None:
				break;
		}
	}
	
	return QString("");
}

// -----------------------------------------------------------------------------

QVariantList CallModel::getAudioStats () const {
	return mAudioStats;
}

QVariantList CallModel::getVideoStats () const {
	return mVideoStats;
}

// -----------------------------------------------------------------------------

static inline QVariantMap createStat (const QString &key, const QString &value) {
	QVariantMap m;
	m["key"] = key;
	m["value"] = value;
	return m;
}

void CallModel::updateStats (const shared_ptr<const linphone::CallStats> &callStats, QVariantList &statsList) {
	if(mCall){
		shared_ptr<const linphone::CallParams> params = mCall->getCurrentParams();
		shared_ptr<const linphone::PayloadType> payloadType;
		
		switch (callStats->getType()) {
			case linphone::StreamType::Audio:
				payloadType = params->getUsedAudioPayloadType();
				break;
			case linphone::StreamType::Video:
				payloadType = params->getUsedVideoPayloadType();
				break;
			default:
				return;
		}
		
		QString family;
		switch (callStats->getIpFamilyOfRemote()) {
			case linphone::AddressFamily::Inet:
				family = QStringLiteral("IPv4");
				break;
			case linphone::AddressFamily::Inet6:
				family = QStringLiteral("IPv6");
				break;
			default:
				family = QStringLiteral("Unknown");
				break;
		}
		
		statsList.clear();
		
		statsList << createStat(tr("callStatsCodec"), payloadType
								? QStringLiteral("%1 / %2kHz").arg(Utils::coreStringToAppString(payloadType->getMimeType())).arg(payloadType->getClockRate() / 1000)
								: QString(""));
		statsList << createStat(tr("callStatsUploadBandwidth"), QStringLiteral("%1 kbits/s").arg(int(callStats->getUploadBandwidth())));
		statsList << createStat(tr("callStatsDownloadBandwidth"), QStringLiteral("%1 kbits/s").arg(int(callStats->getDownloadBandwidth())));
		statsList << createStat(tr("callStatsIceState"), iceStateToString(callStats->getIceState()));
		statsList << createStat(tr("callStatsIpFamily"), family);
		statsList << createStat(tr("callStatsSenderLossRate"), QStringLiteral("%1 %").arg(static_cast<double>(callStats->getSenderLossRate())));
		statsList << createStat(tr("callStatsReceiverLossRate"), QStringLiteral("%1 %").arg(static_cast<double>(callStats->getReceiverLossRate())));
		
		switch (callStats->getType()) {
			case linphone::StreamType::Audio:
				statsList << createStat(tr("callStatsJitterBuffer"), QStringLiteral("%1 ms").arg(callStats->getJitterBufferSizeMs()));
				break;
			case linphone::StreamType::Video: {
				statsList << createStat(tr("callStatsEstimatedDownloadBandwidth"), QStringLiteral("%1 kbits/s").arg(int(callStats->getEstimatedDownloadBandwidth())));
				const QString sentVideoDefinitionName = Utils::coreStringToAppString(params->getSentVideoDefinition()->getName());
				const QString sentVideoDefinition = QStringLiteral("%1x%2")
						.arg(params->getSentVideoDefinition()->getWidth())
						.arg(params->getSentVideoDefinition()->getHeight());
				
				statsList << createStat(tr("callStatsSentVideoDefinition"), sentVideoDefinition == sentVideoDefinitionName
										? sentVideoDefinition
										: QStringLiteral("%1 (%2)").arg(sentVideoDefinition).arg(sentVideoDefinitionName));
				
				const QString receivedVideoDefinitionName = Utils::coreStringToAppString(params->getReceivedVideoDefinition()->getName());
				const QString receivedVideoDefinition = QString("%1x%2")
						.arg(params->getReceivedVideoDefinition()->getWidth())
						.arg(params->getReceivedVideoDefinition()->getHeight());
				
				statsList << createStat(tr("callStatsReceivedVideoDefinition"), receivedVideoDefinition == receivedVideoDefinitionName
										? receivedVideoDefinition
										: QString("%1 (%2)").arg(receivedVideoDefinition).arg(receivedVideoDefinitionName));
				
				statsList << createStat(tr("callStatsReceivedFramerate"), QStringLiteral("%1 FPS").arg(static_cast<double>(params->getReceivedFramerate())));
				statsList << createStat(tr("callStatsSentFramerate"), QStringLiteral("%1 FPS").arg(static_cast<double>(params->getSentFramerate())));
			} break;
				
			default:
				break;
		}
	}
}

// -----------------------------------------------------------------------------

QString CallModel::iceStateToString (linphone::IceState state) const {
	switch (state) {
		case linphone::IceState::NotActivated:
			return tr("iceStateNotActivated");
		case linphone::IceState::Failed:
			return tr("iceStateFailed");
		case linphone::IceState::InProgress:
			return tr("iceStateInProgress");
		case linphone::IceState::ReflexiveConnection:
			return tr("iceStateReflexiveConnection");
		case linphone::IceState::HostConnection:
			return tr("iceStateHostConnection");
		case linphone::IceState::RelayConnection:
			return tr("iceStateRelayConnection");
	}
	
	return tr("iceStateInvalid");
}

// -----------------------------------------------------------------------------

QString CallModel::generateSavedFilename () const {
	const shared_ptr<linphone::CallLog> callLog(mCall->getCallLog());
	return generateSavedFilename(
				Utils::coreStringToAppString(callLog->getFromAddress()->getUsername()),
				Utils::coreStringToAppString(callLog->getToAddress()->getUsername())
				);
}

QString CallModel::generateSavedFilename (const QString &from, const QString &to) {
	auto escape = [](const QString &str) {
		constexpr char ReservedCharacters[] = "[<|>|:|\"|/|\\\\|\\?|\\*|\\+|\\|]+";
		static QRegularExpression regexp(ReservedCharacters);
		return QString(str).replace(regexp, "");
	};
	return QStringLiteral("%1_%2_%3")
			.arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss"))
			.arg(escape(from))
			.arg(escape(to));
}
