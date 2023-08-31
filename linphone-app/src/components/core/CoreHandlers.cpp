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

#include <QMutex>
#include <QtDebug>
#include <QSettings>
#include <QThread>
#include <QTimer>

#include "app/App.hpp"
#include "components/call/CallModel.hpp"
#include "components/chat-events/ChatMessageModel.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "components/timeline/TimelineListModel.hpp"
#include "utils/Utils.hpp"

#include "CoreHandlers.hpp"
#include "CoreListener.hpp"
#include "CoreManager.hpp"

// =============================================================================

using namespace std;

// -----------------------------------------------------------------------------
void CoreHandlers::connectTo(CoreListener * listener){
	connect(listener, &CoreListener::accountRegistrationStateChanged, this, &CoreHandlers::onAccountRegistrationStateChanged);
	connect(listener, &CoreListener::authenticationRequested, this, &CoreHandlers::onAuthenticationRequested);
	connect(listener, &CoreListener::callEncryptionChanged, this, &CoreHandlers::onCallEncryptionChanged);
	connect(listener, &CoreListener::callLogUpdated, this, &CoreHandlers::onCallLogUpdated);
	connect(listener, &CoreListener::callStateChanged, this, &CoreHandlers::onCallStateChanged);
	connect(listener, &CoreListener::callStatsUpdated, this, &CoreHandlers::onCallStatsUpdated);
	connect(listener, &CoreListener::callCreated, this, &CoreHandlers::onCallCreated);
	connect(listener, &CoreListener::chatRoomRead, this, &CoreHandlers::onChatRoomRead);
	connect(listener, &CoreListener::chatRoomStateChanged, this, &CoreHandlers::onChatRoomStateChanged);
	connect(listener, &CoreListener::configuringStatus, this, &CoreHandlers::onConfiguringStatus);
	connect(listener, &CoreListener::dtmfReceived, this, &CoreHandlers::onDtmfReceived);
	connect(listener, &CoreListener::globalStateChanged, this, &CoreHandlers::onGlobalStateChanged);
	connect(listener, &CoreListener::isComposingReceived, this, &CoreHandlers::onIsComposingReceived);
	connect(listener, &CoreListener::logCollectionUploadStateChanged, this, &CoreHandlers::onLogCollectionUploadStateChanged);
	connect(listener, &CoreListener::logCollectionUploadProgressIndication, this, &CoreHandlers::onLogCollectionUploadProgressIndication);
	connect(listener, &CoreListener::messageReceived, this, &CoreHandlers::onMessageReceived);
	connect(listener, &CoreListener::messagesReceived, this, &CoreHandlers::onMessagesReceived);
	connect(listener, &CoreListener::newMessageReaction, this, &CoreHandlers::onNewMessageReaction);
	connect(listener, &CoreListener::notifyPresenceReceivedForUriOrTel, this, &CoreHandlers::onNotifyPresenceReceivedForUriOrTel);
	connect(listener, &CoreListener::notifyPresenceReceived, this, &CoreHandlers::onNotifyPresenceReceived);
	connect(listener, &CoreListener::qrcodeFound, this, &CoreHandlers::onQrcodeFound);
	connect(listener, &CoreListener::transferStateChanged, this, &CoreHandlers::onTransferStateChanged);
	connect(listener, &CoreListener::versionUpdateCheckResultReceived, this, &CoreHandlers::onVersionUpdateCheckResultReceived);
	connect(listener, &CoreListener::ecCalibrationResult, this, &CoreHandlers::onEcCalibrationResult);
	connect(listener, &CoreListener::conferenceInfoReceived, this, &CoreHandlers::onConferenceInfoReceived);
	
}
	
	
CoreHandlers::CoreHandlers (CoreManager *coreManager) {
	mCoreListener = std::make_shared<CoreListener>();
	connectTo(mCoreListener.get());
}

CoreHandlers::~CoreHandlers () {
}

void CoreHandlers::setListener(std::shared_ptr<linphone::Core> core){
	core->addListener(mCoreListener);
}
void CoreHandlers::removeListener(std::shared_ptr<linphone::Core> core){
	core->removeListener(mCoreListener);
}


// -----------------------------------------------------------------------------
void CoreHandlers::onAccountRegistrationStateChanged (
		const shared_ptr<linphone::Core> &,
		const shared_ptr<linphone::Account> &account,
		linphone::RegistrationState state,
		const string &
		) {
	emit registrationStateChanged(account, state);
}

void CoreHandlers::onAuthenticationRequested (
		const shared_ptr<linphone::Core> & core,
		const shared_ptr<linphone::AuthInfo> &authInfo,
		linphone::AuthMethod method
		) {
	Q_UNUSED(method)
	if( authInfo ) {
		auto accounts = CoreManager::getInstance()->getAccountList();
		auto itAccount = accounts.begin() ;
		std::string username = authInfo->getUsername();
		std::string domain = authInfo->getDomain();
		while(itAccount != accounts.end()) {
			auto contact = (*itAccount)->getParams()->getIdentityAddress();
			if( contact && contact->getUsername() == username && contact->getDomain() == domain) {
				emit authenticationRequested(authInfo);// Send authentification request only if an account still exists
				return;
			}else
				++itAccount;
		}
	}
}

void CoreHandlers::onCallEncryptionChanged (
		const shared_ptr<linphone::Core> &,
		const shared_ptr<linphone::Call> &call,
		bool,
		const string &
		) {
	emit callEncryptionChanged(call);
}

void CoreHandlers::onCallLogUpdated(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<linphone::CallLog> & callLog){
	emit callLogUpdated(callLog);
}

void CoreHandlers::onCallStateChanged (
		const shared_ptr<linphone::Core> &,
		const shared_ptr<linphone::Call> &call,
		linphone::Call::State state,
		const string &
		) {
	emit callStateChanged(call, state);
	
	SettingsModel *settingsModel = CoreManager::getInstance()->getSettingsModel();
	if (
			call->getState() == linphone::Call::State::IncomingReceived && (
				!settingsModel->getAutoAnswerStatus() ||
				settingsModel->getAutoAnswerDelay() > 0
				)
			)
		App::getInstance()->getNotifier()->notifyReceivedCall(call);
}

void CoreHandlers::onCallStatsUpdated (
		const shared_ptr<linphone::Core> &,
		const shared_ptr<linphone::Call> &call,
		const shared_ptr<const linphone::CallStats> &stats
		) {
	if(call->dataExists("call-model"))
		call->getData<CallModel>("call-model").updateStats(stats);
}

void CoreHandlers::onCallCreated(const shared_ptr<linphone::Core> &,
								 const shared_ptr<linphone::Call> &call) {
	emit callCreated(call);
}

void CoreHandlers::onChatRoomRead(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<linphone::ChatRoom> & chatRoom){
	emit chatRoomRead(chatRoom);
}

void CoreHandlers::onChatRoomStateChanged(
		const std::shared_ptr<linphone::Core> & core, 
		const std::shared_ptr<linphone::ChatRoom> & chatRoom,
		linphone::ChatRoom::State state
		) {
	if (core->getGlobalState() == linphone::GlobalState::On)
		emit chatRoomStateChanged(chatRoom, state);
}

void CoreHandlers::onConfiguringStatus(
		const std::shared_ptr<linphone::Core> & core,
		linphone::Config::ConfiguringState status,
		const std::string & message){
	Q_UNUSED(core)
	emit setLastRemoteProvisioningState(status);
	if(status == linphone::Config::ConfiguringState::Failed){
		qWarning() << "Remote provisioning has failed and was removed : "<< QString::fromStdString(message);
		core->setProvisioningUri("");
	}
}

void CoreHandlers::onDtmfReceived(
		const std::shared_ptr<linphone::Core> & lc,
		const std::shared_ptr<linphone::Call> & call,
		int dtmf) {
	Q_UNUSED(lc)
	Q_UNUSED(call)
	CoreManager::getInstance()->getCore()->playDtmf((char)dtmf, CallModel::DtmfSoundDelay);
}
void CoreHandlers::onGlobalStateChanged (
		const shared_ptr<linphone::Core> &core,
		linphone::GlobalState gstate,
		const string & message
		) {
	Q_UNUSED(core)
	Q_UNUSED(message)
	switch(gstate){
		case linphone::GlobalState::On :
			qInfo() << "Core is running " << QString::fromStdString(message);
			emit coreStarted();
			break;
		case linphone::GlobalState::Off :
			qInfo() << "Core is stopped " << QString::fromStdString(message);
			emit coreStopped();
			break;
		case linphone::GlobalState::Startup : // Usefull to start core iterations
			qInfo() << "Core is starting " << QString::fromStdString(message);
			emit coreStarting();
			break;
		default:{}
	}
}

void CoreHandlers::onIsComposingReceived (
		const shared_ptr<linphone::Core> &,
		const shared_ptr<linphone::ChatRoom> &room
		) {
	emit isComposingChanged(room);
}

void CoreHandlers::onLogCollectionUploadStateChanged (
		const shared_ptr<linphone::Core> &,
		linphone::Core::LogCollectionUploadState state,
		const string &info
		) {
	emit logsUploadStateChanged(state, info);
}

void CoreHandlers::onLogCollectionUploadProgressIndication (
		const shared_ptr<linphone::Core> &,
		size_t,
		size_t
		) {
	// TODO;
}

void CoreHandlers::onMessageReceived (
		const shared_ptr<linphone::Core> &core,
		const shared_ptr<linphone::ChatRoom> &chatRoom,
		const shared_ptr<linphone::ChatMessage> &message
		) {
	onMessagesReceived(core, chatRoom, std::list<shared_ptr<linphone::ChatMessage>>{message});
}

void CoreHandlers::onMessagesReceived (
		const shared_ptr<linphone::Core> &core,
		const shared_ptr<linphone::ChatRoom> &chatRoom,
		const std::list<shared_ptr<linphone::ChatMessage>> &messages
		) {
	std::list<shared_ptr<linphone::ChatMessage>> messagesToSignal;
	std::list<shared_ptr<linphone::ChatMessage>> messagesToNotify;
	CoreManager *coreManager = CoreManager::getInstance();
	SettingsModel *settingsModel = coreManager->getSettingsModel();
	const App *app = App::getInstance();
	QStringList notNotifyReasons;
	QSettings appSettings;
	
	appSettings.beginGroup("chatrooms");
	for(auto message : messages){
		if(message) ChatMessageModel::initReceivedTimestamp(message, true);
		if( !message || message->isOutgoing()  )
			continue;
		// 1. Do not notify if chat is not activated.
		if (chatRoom->getCurrentParams()->getEncryptionBackend() == linphone::ChatRoom::EncryptionBackend::None && !settingsModel->getStandardChatEnabled()
			|| chatRoom->getCurrentParams()->getEncryptionBackend() != linphone::ChatRoom::EncryptionBackend::None && !settingsModel->getSecureChatEnabled())
			continue;
			
		messagesToSignal.push_back(message);
		
		// 2. Do not notify if the chatroom's notification has been deactivated.
		appSettings.beginGroup(ChatRoomModel::getChatRoomId(chatRoom));
		if(!appSettings.value("notifications", true).toBool()){
			appSettings.endGroup();
			continue;
		}else{
			appSettings.endGroup();
		}
		
		// 3. Notify with Notification popup.
		if (coreManager->getSettingsModel()->getChatNotificationsEnabled() 
				&& (!app->hasFocus() || !Utils::isMe(chatRoom->getLocalAddress()))
				&& !message->isRead())// On aggregation, the list can contains already displayed messages.
			messagesToNotify.push_back(message);
		else{
			notNotifyReasons.push_back(
				"NotifEnabled=" + QString::number(coreManager->getSettingsModel()->getChatNotificationsEnabled())
				+" focus=" +QString::number(app->hasFocus())
				+" isMe=" +QString::number(Utils::isMe(chatRoom->getLocalAddress()))
				+" isRead=" +QString::number(message->isRead())
			);
		}
	}
	if( messagesToSignal.size() > 0)
		emit messagesReceived(messagesToSignal);
	if( messagesToNotify.size() > 0)
		app->getNotifier()->notifyReceivedMessages(messagesToNotify);
	else if( notNotifyReasons.size() > 0)
		qInfo() << "Notification received but was not selected to popup. Reasons : \n" << notNotifyReasons.join("\n");
	// 3. Notify with sound.
	if( messagesToNotify.size() > 0) {
		if (!coreManager->getSettingsModel()->getChatNotificationsEnabled() || !settingsModel->getChatNotificationSoundEnabled())
			return;
	
		if ( !app->hasFocus() || !CoreManager::getInstance()->getTimelineListModel()->getChatRoomModel(chatRoom, false) )
			core->playLocal(Utils::appStringToCoreString(settingsModel->getChatNotificationSoundPath()));
	}
}

void CoreHandlers::onNewMessageReaction(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ChatMessageReaction> & reaction){
	QList<QPair<shared_ptr<linphone::ChatMessage>, std::shared_ptr<const linphone::ChatMessageReaction> >> reactionsToNotify;
	CoreManager *coreManager = CoreManager::getInstance();
	SettingsModel *settingsModel = coreManager->getSettingsModel();
	const App *app = App::getInstance();
	QStringList notNotifyReasons;
	QSettings appSettings;
	
	appSettings.beginGroup("chatrooms");
	
	if( !message || CoreManager::getInstance()->getAccountSettingsModel()->findAccount(reaction->getFromAddress()))
		return;
	// 1. Do not notify if chat is not activated.
	if (chatRoom->getCurrentParams()->getEncryptionBackend() == linphone::ChatRoom::EncryptionBackend::None && !settingsModel->getStandardChatEnabled()
		|| chatRoom->getCurrentParams()->getEncryptionBackend() != linphone::ChatRoom::EncryptionBackend::None && !settingsModel->getSecureChatEnabled())
		return;
		
	// 2. Do not notify if the chatroom's notification has been deactivated.
	appSettings.beginGroup(ChatRoomModel::getChatRoomId(chatRoom));
	if(!appSettings.value("notifications", true).toBool()){
		appSettings.endGroup();
		return;
	}else{
		appSettings.endGroup();
	}
	// 3. Notify with Notification popup.
	if (coreManager->getSettingsModel()->getChatNotificationsEnabled() 
			&& (!app->hasFocus() || !Utils::isMe(chatRoom->getLocalAddress())))
		reactionsToNotify.push_back({message, reaction});
	else{
		notNotifyReasons.push_back(
			"NotifEnabled=" + QString::number(coreManager->getSettingsModel()->getChatNotificationsEnabled())
			+" focus=" +QString::number(app->hasFocus())
			+" isMe=" +QString::number(Utils::isMe(chatRoom->getLocalAddress()))
		);
	}
	if( reactionsToNotify.size() > 0)
		app->getNotifier()->notifyReceivedReactions(reactionsToNotify);
	else if( notNotifyReasons.size() > 0)
		qInfo() << "Notification received but was not selected to popup. Reasons : \n" << notNotifyReasons.join("\n");
	// 3. Notify with sound.
	if( reactionsToNotify.size() > 0) {
		if (!coreManager->getSettingsModel()->getChatNotificationsEnabled() || !settingsModel->getChatNotificationSoundEnabled())
			return;
	
		if ( !app->hasFocus() || !CoreManager::getInstance()->getTimelineListModel()->getChatRoomModel(chatRoom, false) )
			core->playLocal(Utils::appStringToCoreString(settingsModel->getChatNotificationSoundPath()));
	}
}

void CoreHandlers::onNotifyPresenceReceivedForUriOrTel (
		const shared_ptr<linphone::Core> &,
		const shared_ptr<linphone::Friend> &,
		const string &uriOrTel,
		const shared_ptr<const linphone::PresenceModel> &presenceModel
		) {
	emit presenceReceived(Utils::coreStringToAppString(uriOrTel), presenceModel);
}

void CoreHandlers::onNotifyPresenceReceived (
		const shared_ptr<linphone::Core> &,
		const shared_ptr<linphone::Friend> &linphoneFriend
		) {
	// Ignore friend without vcard because the `contact-model` data doesn't exist.
	if (linphoneFriend->getVcard() && linphoneFriend->dataExists("contact-model"))
		linphoneFriend->getData<ContactModel>("contact-model").refreshPresence();
	emit presenceStatusReceived(linphoneFriend);
}

void CoreHandlers::onQrcodeFound(const std::shared_ptr<linphone::Core> & core, const std::string & result){
	emit foundQRCode(result);
}

void CoreHandlers::onTransferStateChanged (
		const shared_ptr<linphone::Core> &,
		const shared_ptr<linphone::Call> &call,
		linphone::Call::State state
		) {
	switch (state) {
		case linphone::Call::State::EarlyUpdatedByRemote:
		case linphone::Call::State::EarlyUpdating:
		case linphone::Call::State::Idle:
		case linphone::Call::State::IncomingEarlyMedia:
		case linphone::Call::State::IncomingReceived:
		case linphone::Call::State::OutgoingEarlyMedia:
		case linphone::Call::State::OutgoingRinging:
		case linphone::Call::State::Paused:
		case linphone::Call::State::PausedByRemote:
		case linphone::Call::State::Pausing:
		case linphone::Call::State::PushIncomingReceived:
		case linphone::Call::State::Referred:
		case linphone::Call::State::Released:
		case linphone::Call::State::Resuming:
		case linphone::Call::State::StreamsRunning:
		case linphone::Call::State::UpdatedByRemote:
		case linphone::Call::State::Updating:
			break; // Nothing.
			
			// 1. Init.
		case linphone::Call::State::OutgoingInit:
			qInfo() << QStringLiteral("Call transfer init.");
			break;
			
			// 2. In progress.
		case linphone::Call::State::OutgoingProgress:
			qInfo() << QStringLiteral("Call transfer in progress.");
			break;
			
			// 3. Done.
		case linphone::Call::State::Connected:
			qInfo() << QStringLiteral("Call transfer succeeded.");
			emit callTransferSucceeded(call);
			break;
			
			// 4. Error.
		case linphone::Call::State::End:
		case linphone::Call::State::Error:
			qWarning() << QStringLiteral("Call transfer failed.");
			emit callTransferFailed(call);
			break;
	}
}

void CoreHandlers::onVersionUpdateCheckResultReceived (
		const shared_ptr<linphone::Core> &,
		linphone::VersionUpdateCheckResult result,
		const string &version,
		const string &url
		) {
	if (result == linphone::VersionUpdateCheckResult::NewVersionAvailable)
		App::getInstance()->getNotifier()->notifyNewVersionAvailable(
					Utils::coreStringToAppString(version),
					Utils::coreStringToAppString(url)
					);
}
void CoreHandlers::onEcCalibrationResult(
		const std::shared_ptr<linphone::Core> &,
		linphone::EcCalibratorStatus status,
		int delayMs
		) {
	emit ecCalibrationResult(status, delayMs);
}

//------------------------------				 CONFERENCE INFO
void CoreHandlers::onConferenceInfoReceived(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<const linphone::ConferenceInfo> & conferenceInfo) {
	qDebug() << "onConferenceInfoReceived: " << conferenceInfo->getUri()->asString().c_str();
	emit conferenceInfoReceived(conferenceInfo);
}
