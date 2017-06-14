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
        handler: call.askForTransfer,
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
        handler: call.acceptWithVideo
      }, {
        name: qsTr('terminateCall'),
        handler: call.terminate
      }],
      component: callActions,
      string: 'incoming'
    }
  })

  map[CallModel.CallStatusOutgoing] = (function (call) {
    return {
      component: callAction,
      handler: call.terminate,
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
        handler: call.askForTransfer,
        name: qsTr('transferCall')
      }, {
        handler: call.terminate,
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
// Helpers.
// -----------------------------------------------------------------------------

function updateSelectedCall (call, index) {
  calls._selectedCall = call
  if (index != null) {
    calls.currentIndex = index
  }
}

function resetSelectedCall () {
  updateSelectedCall(null, -1)
}

function setIndexWithCall (call) {
  var count = calls.count
  var model = calls.model

  for (var i = 0; i < count; i++) {
    if (call === model.data(model.index(i, 0))) {
      updateSelectedCall(call, i)
      return
    }
  }

  updateSelectedCall(call, -1)
}

// -----------------------------------------------------------------------------
// View handlers.
// -----------------------------------------------------------------------------

function handleCountChanged (count) {
  if (count === 0) {
    return
  }

  var call = calls._selectedCall

  if (call == null) {
    if (calls.conferenceModel.count > 0) {
      return
    }

    var model = calls.model
    var index = count - 1
    updateSelectedCall(model.data(model.index(index, 0)), index)
  } else {
    setIndexWithCall(call)
  }
}

// -----------------------------------------------------------------------------
// Model handlers.
// -----------------------------------------------------------------------------

function handleCallRunning (call) {
  if (!call.isInConference) {
    setIndexWithCall(call)
  }
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

    if (call.isOutgoing && !call.isInConference) {
      updateSelectedCall(call)
      return
    }
  }

  // First received call.
  if (first === 0 && model.rowCount() === 1) {
    var call = model.data(model.index(0, 0))
    if (!call.isInConference) {
      updateSelectedCall(model.data(model.index(0, 0)))
    }
  }
}
