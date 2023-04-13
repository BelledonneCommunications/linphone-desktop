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

#include "CoreListener.hpp"

// =============================================================================


// -----------------------------------------------------------------------------

CoreListener::CoreListener(QObject * parent): QObject(parent){
}
CoreListener::~CoreListener(){
}

void CoreListener::onAccountRegistrationStateChanged(const std::shared_ptr<linphone::Core> & core,const std::shared_ptr<linphone::Account> & account,linphone::RegistrationState state,const std::string & message){
	emit accountRegistrationStateChanged(core,account,state,message);
}
void CoreListener::onAuthenticationRequested (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::AuthInfo> &authInfo,linphone::AuthMethod method){
	emit authenticationRequested (core,authInfo,method);
}
void CoreListener::onCallEncryptionChanged (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Call> &call,bool on,const std::string &authenticationToken){
	emit callEncryptionChanged (core,call,on,authenticationToken);
}
void CoreListener::onCallLogUpdated(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<linphone::CallLog> & callLog){
	emit callLogUpdated(core, callLog);
}
void CoreListener::onCallStateChanged (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Call> &call,linphone::Call::State state,const std::string &message){
	emit callStateChanged (core,call,state,message);
}
void CoreListener::onCallStatsUpdated (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Call> &call,const std::shared_ptr<const linphone::CallStats> &stats){
	emit callStatsUpdated (core,call,stats);
}
void CoreListener::onCallCreated(const std::shared_ptr<linphone::Core> & lc,const std::shared_ptr<linphone::Call> & call){
	emit callCreated(lc,call);
}
void CoreListener::onChatRoomRead(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<linphone::ChatRoom> & chatRoom){
	emit chatRoomRead(core, chatRoom);
}
void CoreListener::onChatRoomStateChanged(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<linphone::ChatRoom> & chatRoom,linphone::ChatRoom::State state){
	emit chatRoomStateChanged(core, chatRoom,state);
}
void CoreListener::onConfiguringStatus(const std::shared_ptr<linphone::Core> & core,linphone::Config::ConfiguringState status,const std::string & message){
	emit configuringStatus(core,status,message);
}
void CoreListener::onDtmfReceived(const std::shared_ptr<linphone::Core> & lc,const std::shared_ptr<linphone::Call> & call,int dtmf){
	emit dtmfReceived(lc,call,dtmf);
}
void CoreListener::onGlobalStateChanged (const std::shared_ptr<linphone::Core> &core,linphone::GlobalState gstate,const std::string &message){
	emit globalStateChanged (core,gstate,message);
}
void CoreListener::onIsComposingReceived (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::ChatRoom> &room){
	emit isComposingReceived (core,room);
}
void CoreListener::onLogCollectionUploadStateChanged (const std::shared_ptr<linphone::Core> &core,linphone::Core::LogCollectionUploadState state,const std::string &info){
	emit logCollectionUploadStateChanged (core,state,info);
}
void CoreListener::onLogCollectionUploadProgressIndication (const std::shared_ptr<linphone::Core> &lc,size_t offset,size_t total){
	emit logCollectionUploadProgressIndication (lc,offset,total);
}
void CoreListener::onMessageReceived (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::ChatRoom> &room,const std::shared_ptr<linphone::ChatMessage> &message){
	emit messageReceived (core,room,message);
}
void CoreListener::onMessagesReceived (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::ChatRoom> &room,const std::list<std::shared_ptr<linphone::ChatMessage>> &messages){
	emit messagesReceived (core,room,messages);
}
void CoreListener::onNotifyPresenceReceivedForUriOrTel (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Friend> &linphoneFriend,const std::string &uriOrTel,const std::shared_ptr<const linphone::PresenceModel> &presenceModel){
	emit notifyPresenceReceivedForUriOrTel (core,linphoneFriend,uriOrTel,presenceModel);
}
void CoreListener::onNotifyPresenceReceived (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Friend> &linphoneFriend){
	emit notifyPresenceReceived (core,linphoneFriend);
}
void CoreListener::onQrcodeFound(const std::shared_ptr<linphone::Core> & core, const std::string & result){
	emit qrcodeFound(core, result);
}
void CoreListener::onTransferStateChanged (const std::shared_ptr<linphone::Core> &core,const std::shared_ptr<linphone::Call> &call,linphone::Call::State state){
	emit transferStateChanged (core,call,state);
}
void CoreListener::onVersionUpdateCheckResultReceived (const std::shared_ptr<linphone::Core> & core,linphone::VersionUpdateCheckResult result,const std::string &version,const std::string &url){
	emit versionUpdateCheckResultReceived (core,result,version,url);
}
void CoreListener::onEcCalibrationResult(const std::shared_ptr<linphone::Core> & core,linphone::EcCalibratorStatus status,int delayMs){
	emit ecCalibrationResult(core,status,delayMs);
}
void CoreListener::onConferenceInfoReceived(const std::shared_ptr<linphone::Core> & core, const std::shared_ptr<const linphone::ConferenceInfo> & conferenceInfo){
	emit conferenceInfoReceived(core, conferenceInfo);
}
