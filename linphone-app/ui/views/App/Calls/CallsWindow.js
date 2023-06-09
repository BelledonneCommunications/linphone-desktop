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
	calls.refreshCall()
	if(window.conferenceInfoModel && middlePane.sourceComponent == waitingRoom)
		middlePane.item.reset()
	window.conferenceInfoModel = model
}

// -----------------------------------------------------------------------------
// Used to get Component based from Call Status
function getContent (call, conferenceInfoModel) {
	if (call == null) {
		if(conferenceInfoModel) {
			console.debug('New Content:' +waitingRoom)
			return waitingRoom
		}
		else{
			console.debug('New Content: null')
			return null
		}
	}
	
	var status = call.status
	if (status == null) {
		var contentView = calls.conferenceModel.count > 0 ? conference : null
		console.debug('New Content: ' +contentView)
		return contentView
	}
	var CallModel = Linphone.CallModel
	if (status === CallModel.CallStatusIncoming) {
		console.debug('New Content: ' +incall)
		return incall;
	}
	if( window.conferenceInfoModel != call.conferenceInfoModel) {
		Qt.callLater(function(){window.conferenceInfoModel = call.conferenceInfoModel})
		console.debug('New Content: ' +middlePane.sourceComponent)
		return middlePane.sourceComponent	// unchange. Wait for later decision on conference model (avoid binding loop on sourceComponent)
	}else{
		if(call.isConference){
			console.debug('New Content: ' +incall)
			return incall
		}
		if (status === CallModel.CallStatusOutgoing || (status === CallModel.CallStatusEnded && call.callError != '' )) {
			console.debug('New Content: ' +waitingRoom)
			return waitingRoom
		}
		console.debug('New Content: ' +incall)
		return incall
	}
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
	return Linphone.CallsListModel.rowCount() === 0 && !window.virtualWindowVisible && middlePane.sourceComponent != waitingRoom
}

function tryToCloseWindow () {
	if (windowMustBeClosed()) {
		// Workaround, it's necessary to use a timeout because at last call termination
		// a segfault is emit in `QOpenGLContext::functions() const ()`.
		Utils.setTimeout(window, 0, function () { windowMustBeClosed() && window.close() })
	}
}
