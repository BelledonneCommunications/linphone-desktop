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

#ifndef CORE_HANDLERS_H_
#define CORE_HANDLERS_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class CoreListener;
class CoreManager;
class QMutex;

class CoreHandlers : public QObject{
	Q_OBJECT
	
public:
	CoreHandlers (CoreManager *coreManager);
	~CoreHandlers ();
	
signals:
	void authenticationRequested (const std::shared_ptr<linphone::AuthInfo> &authInfo);
	void callEncryptionChanged (const std::shared_ptr<linphone::Call> &call);
	void callLogUpdated(const std::shared_ptr<linphone::CallLog> &call);
	void callStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state);
	void callTransferFailed (const std::shared_ptr<linphone::Call> &call);
	void callTransferSucceeded (const std::shared_ptr<linphone::Call> &call);
	void callCreated(const std::shared_ptr<linphone::Call> & call);
	void chatRoomRead(const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	void chatRoomStateChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,linphone::ChatRoom::State state);
	void coreStarting();
	void coreStarted ();
	void coreStopped ();
	void isComposingChanged (const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	void logsUploadStateChanged (linphone::Core::LogCollectionUploadState state, const std::string &info);
	void messagesReceived (const std::list<std::shared_ptr<linphone::ChatMessage>> &messages);
	void newMessageReaction(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ChatMessageReaction> & reaction);
	void presenceReceived (const QString &sipAddress, const std::shared_ptr<const linphone::PresenceModel> &presenceModel);
	void presenceStatusReceived(std::shared_ptr<linphone::Friend> contact);
	void registrationStateChanged (const std::shared_ptr<linphone::Account> &account, linphone::RegistrationState state);
	void ecCalibrationResult(linphone::EcCalibratorStatus status, int delayMs);
	void setLastRemoteProvisioningState(const linphone::Config::ConfiguringState &state);
	void conferenceInfoReceived(const std::shared_ptr<const linphone::ConferenceInfo> & conferenceInfo);
	void foundQRCode(const std::string & result);

	//--------------------		CORE HANDLER
	
public slots:

	void onAccountRegistrationStateChanged(const std::shared_ptr<linphone::Core> & core,const std::shared_ptr<linphone::Account> & account,linphone::RegistrationState state,const std::string & message);
	void onAuthenticationRequested (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::AuthInfo> &authInfo,linphone::AuthMethod method);
	void onCallEncryptionChanged (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Call> &call,bool on,const std::string &authenticationToken);
	void onCallLogUpdated(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<linphone::CallLog> & callLog);
	void onCallStateChanged (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Call> &call,linphone::Call::State state,const std::string &message);
	void onCallStatsUpdated (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Call> &call,const std::shared_ptr<const linphone::CallStats> &stats);
	void onCallCreated(const std::shared_ptr<linphone::Core> & lc,const std::shared_ptr<linphone::Call> & call);
	void onChatRoomRead(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<linphone::ChatRoom> & chatRoom);
	void onChatRoomStateChanged(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<linphone::ChatRoom> & chatRoom,linphone::ChatRoom::State state);
	void onConfiguringStatus(const std::shared_ptr<linphone::Core> & core,linphone::Config::ConfiguringState status,const std::string & message);
	void onDtmfReceived(const std::shared_ptr<linphone::Core> & lc,const std::shared_ptr<linphone::Call> & call,int dtmf);
	void onGlobalStateChanged (const std::shared_ptr<linphone::Core> &core,linphone::GlobalState gstate,const std::string &message);
	void onIsComposingReceived (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::ChatRoom> &room);
	void onLogCollectionUploadStateChanged (const std::shared_ptr<linphone::Core> &core,linphone::Core::LogCollectionUploadState state,const std::string &info);
	void onLogCollectionUploadProgressIndication (const std::shared_ptr<linphone::Core> &lc,size_t offset,size_t total);
	void onMessageReceived (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::ChatRoom> &room,const std::shared_ptr<linphone::ChatMessage> &message);
	void onMessagesReceived (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::ChatRoom> &room,const std::list<std::shared_ptr<linphone::ChatMessage>> &messages);
	void onNewMessageReaction(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ChatMessageReaction> & reaction);
	void onNotifyPresenceReceivedForUriOrTel (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Friend> &linphoneFriend,const std::string &uriOrTel,const std::shared_ptr<const linphone::PresenceModel> &presenceModel);
	void onNotifyPresenceReceived (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Friend> &linphoneFriend);
	void onQrcodeFound(const std::shared_ptr<linphone::Core> & core, const std::string & result);
	void onTransferStateChanged (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Call> &call,linphone::Call::State state);
	void onVersionUpdateCheckResultReceived (const std::shared_ptr<linphone::Core> & core,linphone::VersionUpdateCheckResult result,const std::string &version,const std::string &url);
	void onEcCalibrationResult(const std::shared_ptr<linphone::Core> & core,linphone::EcCalibratorStatus status,int delayMs);
	void onConferenceInfoReceived(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<const linphone::ConferenceInfo> & conferenceInfo);
	
	void setListener(std::shared_ptr<linphone::Core> core);
	void removeListener(std::shared_ptr<linphone::Core> core);
	
private:
	void connectTo(CoreListener * listener);
	std::shared_ptr<CoreListener> mCoreListener;	// This need to be a shared_ptr because of adding it to linphone
};

#endif // CORE_HANDLERS_H_
