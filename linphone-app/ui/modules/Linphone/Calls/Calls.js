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
// `Calls.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

// =============================================================================

// -----------------------------------------------------------------------------
// Helpers.
// -----------------------------------------------------------------------------

function getParams (call) {
  if (!call) {
    return
  }

  var CallModel = Linphone.CallModel
  var status = call.status

  if (status === CallModel.CallStatusConnected) {
    var optActions = []
    if (Linphone.SettingsModel.callPauseEnabled) {
      optActions.push({
        handler: (function () { call.pausedByUser = true }),
        name: qsTr('callPause')
      })
    }

    return {
      actions: optActions.concat([{
        handler: call.askForTransfer,
        name: qsTr('transferCall')
      }, {
        handler: call.terminate,
        name: qsTr('terminateCall')
      }]),
      component: callActions,
      string: 'connected'
    }
  }

  if (status === CallModel.CallStatusEnded) {
    return {
      string: 'ended'
    }
  }

  if (status === CallModel.CallStatusIncoming) {
    var optActions = []
    if (Linphone.SettingsModel.videoSupported) {
      optActions.push({
        handler: call.acceptWithVideo,
        name: qsTr('acceptVideoCall')
      })
    }

    return {
      actions: [{
        handler: (function () { call.accept() }),
        name: qsTr('acceptAudioCall')
      }].concat(optActions).concat([{
        handler: call.terminate,
        name: qsTr('terminateCall')
      }]),
      component: callActions,
      string: 'incoming'
    }
  }

  if (status === CallModel.CallStatusOutgoing) {
    return {
      component: callAction,
      handler: call.terminate,
      icon: 'hangup',
      string: 'outgoing'
    }
  }

  if (status === CallModel.CallStatusPaused) {
    var optActions = []
    if (call.pausedByUser) {
      optActions.push({
        handler: (function () { call.pausedByUser = false }),
        name: qsTr('resumeCall')
      })
    } else if (Linphone.SettingsModel.callPauseEnabled) {
      optActions.push({
        handler: (function () { call.pausedByUser = true }),
        name: qsTr('callPause')
      })
    }

    return {
      actions: optActions.concat([{
        handler: call.askForTransfer,
        name: qsTr('transferCall')
      }, {
        handler: call.terminate,
        name: qsTr('terminateCall')
      }]),
      component: callActions,
      string: 'paused'
    }
  }
}

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
