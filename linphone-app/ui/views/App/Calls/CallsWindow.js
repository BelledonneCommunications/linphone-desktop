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
// =============================================================================
// `CallsWindow.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function handleClosing (close) {
	var callsList = Linphone.CallsListModel
	
	window.detachVirtualWindow()
	
	if (callsList.getRunningCallsNumber() === 0) {
		return
	}
	
	window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
								   descriptionText: qsTr('acceptClosingDescription')
							   }, function (status) {
								   if (status) {
									   callsList.terminateAllCalls()
									   window.close()
								   }
							   })
	close.accepted = false
}

// -----------------------------------------------------------------------------

function openCallSipAddress () {
	window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/CallSipAddress.qml'))
}

function openConferenceManager (params, exitHandler) {
	window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/ConferenceManager.qml'), params, exitHandler)
}

function openWaitingRoom(model){
	if(window.conferenceInfoModel)
		window.conferenceInfoModel = null;
	window.conferenceInfoModel = model
}

// -----------------------------------------------------------------------------
// Used to get Component based from Call Status
function getContent (call, conferenceInfoModel) {
	if (call == null) {
		if(conferenceInfoModel)
			return waitingRoom
		else
			return null
	}
	
	var status = call.status
	if (status == null) {
		return calls.conferenceModel.count > 0 ? conference : null
	}
	var CallModel = Linphone.CallModel
	if (status === CallModel.CallStatusIncoming) {
		return incomingCall
	}
	window.conferenceInfoModel = call.conferenceInfoModel;
	if (status === CallModel.CallStatusOutgoing || status === CallModel.CallStatusEnded) {
		return waitingRoom
	}
	
	if(call.isConference)
		return videoConference
		
	return videoConference	//incall
}

// -----------------------------------------------------------------------------

function handleCallTransferAsked (call) {
	if (!call) {
		return
	}
	
	if (call.transferAddress !== '') {
		console.debug('Attended transfer to call ' + call.transferAddress)
		call.transferToAnother(call.transferAddress)
		return
	}
	
	window.detachVirtualWindow()
	window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/CallTransfer.qml'), {
								   call: call,
								   attended: false
							   })
}

function handleCallAttendedTransferAsked (call) {
	if (!call) {
		return
	}
	if (call.transferAddress !== '') {
		console.debug('Attended transfer to call ' + call.transferAddress)
		call.transferToAnother(call.transferAddress)
		return
	}
	window.detachVirtualWindow()
	window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/CallTransfer.qml'), {
									call: call,
									attended: true
							   })
}

function windowMustBeClosed () {
	return Linphone.CallsListModel.rowCount() === 0 && !window.virtualWindowVisible
}

function tryToCloseWindow () {
	if (windowMustBeClosed()) {
		// Workaround, it's necessary to use a timeout because at last call termination
		// a segfault is emit in `QOpenGLContext::functions() const ()`.
		Utils.setTimeout(window, 0, function () { windowMustBeClosed() && window.close() })
	}
}
