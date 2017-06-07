// =============================================================================
// `Incall.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function computeAvatarSize (maxSize) {
  var height = container.height
  var width = container.width

  var size = height < maxSize && height > 0 ? height : maxSize
  return size < width ? size : width
}

function handleStatusChanged (status) {
  if (status === Linphone.CallModel.CallStatusEnded) {
    var fullscreen = incall._fullscreen
    if (fullscreen) {
      fullscreen.exit()
    }

    telKeypad.visible = false
    callStatistics.close()
  }
}

function handleVideoRequested () {
  var call = incall.call

  // Close dialog after 10s.
  var timeout = Utils.setTimeout(incall, 10000, function () {
    call.statusChanged.disconnect(endedHandler)
    window.detachVirtualWindow()
    call.rejectVideoRequest()
  })

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
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('acceptVideoDescription'),
  }, function (status) {
    Utils.clearTimeout(timeout)
    call.statusChanged.disconnect(endedHandler)

    if (status) {
      call.acceptVideoRequest()
    } else {
      call.rejectVideoRequest()
    }
  })
}

function showFullscreen () {
  if (incall._fullscreen) {
    return
  }

  incall._fullscreen = Utils.openWindow(Qt.resolvedUrl('IncallFullscreenWindow.qml'), incall, {
    properties: {
      call: incall.call,
      callsWindow: incall
    }
  })
}

function updateCallQualityIcon () {
  var quality = call.quality
  callQuality.icon = 'call_quality_' + (
    // Note: `quality` is in the [0, 5] interval.
    // It's necessary to map in the `call_quality_` interval. ([0, 3])
    quality >= 0 ? Math.round(quality / (5 / 3)) : 0
  )
}
