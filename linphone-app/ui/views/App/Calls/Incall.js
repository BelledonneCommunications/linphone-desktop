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

function computeAvatarSize (container, maxSize) {
  var height = container.height
  var width = container.width

  var size = height < maxSize && height > 0 ? height : maxSize
  return size < width ? size : width
}

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

function handleStatusChanged (status) {
  if (status === Linphone.CallModel.CallStatusEnded) {
    var fullscreen = incall._fullscreen
    if (fullscreen) {
      // Timeout => Avoid dead lock on mac.
      Utils.setTimeout(window, 0, fullscreen.exit)
    }

    telKeypad.visible = false
    callStatistics.close()
  }
}

function handleVideoRequested (call) {
  console.log("handleVideoRequested")
  if (window.virtualWindowVisible || !Linphone.SettingsModel.videoSupported) {
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
console.log("D")
  // Ask video to user.
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('acceptVideoDescription'),
  }, function (status) {
    //Utils.clearTimeout(timeout)	
    call.statusChanged.disconnect(endedHandler)
	console.log("E: "+status)
    if (status) {
		console.log("TOTO")
      call.acceptVideoRequest()
    } else {
      call.rejectVideoRequest()
    }
  })
}

function makeReadableSecuredString (securedString) {
  if (!securedString || !securedString.length) {
    return qsTr('callNotSecured')
  }

  return qsTr('securedStringFormat').replace('%1', securedString)
}

function openCallStatistics () {
  callQuality.enabled = false
  callStatistics.open()
}

function openMediaParameters (window, incall) {
  window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/MultimediaParameters.qml'), {
    call: incall.call
  })
}

function showFullscreen (position) {
  incall.isFullScreen = true
  if (incall._fullscreen) {
    incall._fullscreen.raise()
    return
  }
  DesktopTools.DesktopTools.screenSaverStatus = false
  var parameters = {
	  caller: incall,
	  x:position.x,
	  y:position.y,
	  width:window.width,
	  height:window.height,
	  window:window
	}
  incall._fullscreen = Utils.openWindow(Qt.resolvedUrl('IncallFullscreenWindow.qml'), parameters.window, {
	properties: parameters
  }, true)
  if(incall._fullscreen) {
	incall._fullscreen.cameraIsReady = Qt.binding(function(){ return !incall.cameraIsReady})
	incall._fullscreen.previewIsReady = Qt.binding(function(){ return !incall.previewIsReady})
  }
}
