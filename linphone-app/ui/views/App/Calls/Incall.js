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
// `Incall.qml` Logic.
// =============================================================================

.import DesktopTools 1.0 as DesktopTools
.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================



function handleCallStatisticsClosed () {
	// Prevent many clicks on call statistics button.
	Utils.setTimeout(callQuality, 500, function () {
		callQuality.enabled = true
	})
}

function handleCameraFirstFrameReceived (width, height) {
	// Cell phone???
	if (height > width) {
		return
	}
	
	var ratio = container.width / (width / (height / container.height))
	var diff = container.height * ratio - container.height
	if (diff < 0) {
		return
	}
	
	window.setHeight(window.height + diff)
}

function handleStatusChanged (status, isFullscreen) {
	if (status === Linphone.CallModel.CallStatusEnded) {
		if (isFullscreen) {
			// Timeout => Avoid dead lock on mac.
			Utils.setTimeout(window, 0, isFullscreen.exit)
		}
		
		telKeypad.visible = false
		callStatistics.close()
	}
}

function handleVideoRequested (call) {
	if (window.virtualWindowVisible || !Linphone.SettingsModel.videoAvailable) {
		call.rejectVideoRequest()
		return
	}
	/*
  // Close dialog after 10s.
  var timeout = Utils.setTimeout(incall, 10000, function () {
	call.statusChanged.disconnect(endedHandler)
	window.detachVirtualWindow()
	call.rejectVideoRequest()
  })
  */
	// Close dialog if call is ended.
	var endedHandler = function (status) {
		if (status === Linphone.CallModel.CallStatusEnded) {
			Utils.clearTimeout(timeout)	
			call.statusChanged.disconnect(endedHandler)
			window.detachVirtualWindow()
		}
	}
	call.statusChanged.connect(endedHandler)
	// Ask video to user.
	window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
								   descriptionText: qsTr('acceptVideoDescription'),
							   }, function (status) {
								   //Utils.clearTimeout(timeout)	
								   call.statusChanged.disconnect(endedHandler)
								   if (status) {
									   call.acceptVideoRequest()
								   } else {
									   call.rejectVideoRequest()
								   }
							   })
}

function makeReadableSecuredString (isSecured, secureString) {
	if (!isSecured) {
		return qsTr('callNotSecured')
	}
	
	return qsTr('securedStringFormat').replace('%1', secureString)
}

function openCallStatistics () {
	callQuality.enabled = false
	callStatistics.open()
}

function openMediaParameters (window, incall) {
	window.attachVirtualWindow(Utils.buildLinphoneDialogUri('MultimediaParametersDialog'), {
								   call: incall.call
							   })
}
// callerId = incall, qmlFile = 'IncallFullscreen.qml'
// callerId need to have : _fullscreen and isFullScreen
function showFullscreen (window, callerId, qmlFile, position) {
	callerId.isFullScreen = true
	if (callerId._fullscreen) {
		callerId._fullscreen.raise()
		return
	}
	DesktopTools.DesktopTools.screenSaverStatus = false
	Utils.setTimeout(window, 1, function() {
		var parameters = {
			caller: callerId,
			x:position.x,
			y:position.y,
			width:window.width,
			height:window.height,
			window:window
		}
		callerId._fullscreen = Utils.openWindow(Qt.resolvedUrl(qmlFile), parameters.window, {
													properties: parameters
												}, true)
		if(callerId._fullscreen) {
			callerId._fullscreen.cameraIsReady = Qt.binding(function(){ return !callerId.cameraIsReady})
			callerId._fullscreen.previewIsReady = Qt.binding(function(){ return !callerId.previewIsReady})
		}
	})
}
