// =============================================================================
// `Calls.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

// =============================================================================

var MAP_STATUS_TO_PARAMS = (function () {
  var CallModel = Linphone.CallModel
  var map = {}

  map[CallModel.CallStatusConnected] = (function (call) {
    return {
      actions: [{
        handler: (function () { call.pausedByUser = true }),
        name: qsTr('pauseCall')
      }, {
        handler: call.transfer,
        name: qsTr('transferCall')
      }, {
        handler: call.terminate,
        name: qsTr('terminateCall')
      }],
      component: callActions,
      string: 'connected'
    }
  })

  map[CallModel.CallStatusEnded] = (function (call) {
    return {
      string: 'ended'
    }
  })

  map[CallModel.CallStatusIncoming] = (function (call) {
    return {
      actions: [{
        name: qsTr('acceptAudioCall'),
        handler: (function () { call.accept() })
      }, {
        name: qsTr('acceptVideoCall'),
        handler: (function () { call.acceptWithVideo() })
      }, {
        name: qsTr('terminateCall'),
        handler: (function () { call.terminate() })
      }],
      component: callActions,
      string: 'incoming'
    }
  })

  map[CallModel.CallStatusOutgoing] = (function (call) {
    return {
      component: callAction,
      handler: (function () { call.terminate() }),
      icon: 'hangup',
      string: 'outgoing'
    }
  })

  map[CallModel.CallStatusPaused] = (function (call) {
    return {
      actions: [(call.pausedByUser ? {
        handler: (function () { call.pausedByUser = false }),
        name: qsTr('resumeCall')
      } : {
        handler: (function () { call.pausedByUser = true }),
        name: qsTr('pauseCall')
      }), {
        handler: (function () { call.transfer() }),
        name: qsTr('transferCall')
      }, {
        handler: (function () { call.terminate() }),
        name: qsTr('terminateCall')
      }],
      component: callActions,
      string: 'paused'
    }
  })

  return map;
})()

// -----------------------------------------------------------------------------

function getParams (call) {
  if (call) {
    return MAP_STATUS_TO_PARAMS[call.status](call)
  }
}

// -----------------------------------------------------------------------------

function handleCallRunning (index, call) {
  calls.currentIndex = index
  calls._selectedCall = call
}

function handleCountChanged (count) {
  if (count === 0) {
    return 0
  }

  var index = calls.currentIndex
  if (index !== -1) {
    return
  }

  var model = calls.model
  index = count - 1

  calls.currentIndex = index
  calls._selectedCall = model.data(model.index(index, 0))
}

function resetSelectedCall () {
  calls.currentIndex = -1
  calls._selectedCall = null
}

function handleRowsAboutToBeRemoved (_, first, last) {
  var index = calls.currentIndex

  if (index >= first && index <= last) {
    resetSelectedCall()
  }
}

function handleRowsInserted (_, first, last) {
  // The last inserted outgoing element become the selected call.
  var model = calls.model
  for (var index = last; index >= first; index--) {
    var call = model.data(model.index(index, 0))

    if (call.isOutgoing) {
      resetSelectedCall()
      return
    }
  }

  // First received call.
  if (first === 0 && model.rowCount() === 1) {
    resetSelectedCall()
  }
}
