import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

ListView {
  id: calls

  // ---------------------------------------------------------------------------

  readonly property var selectedCall: _selectedCall

  property var _mapStatusToParams
  property var _selectedCall

  // ---------------------------------------------------------------------------

  function _getParams (call) {
    if (call) {
      return _mapStatusToParams[call.status](call)
    }
  }

  // ---------------------------------------------------------------------------

  boundsBehavior: Flickable.StopAtBounds
  clip: true
  spacing: 0

  // ---------------------------------------------------------------------------

  Component.onCompleted: {
    _mapStatusToParams = {}

    _mapStatusToParams[CallModel.CallStatusConnected] = (function (call) {
      return {
        actions: [{
          handler: (function () { call.pausedByUser = true }),
          name: qsTr('pauseCall')
        }, {
          handler: (function () { call.transfer() }),
          name: qsTr('transferCall')
        }, {
          handler: (function () { call.terminate() }),
          name: qsTr('terminateCall')
        }],
        component: callActions,
        string: 'connected'
      }
    })

    _mapStatusToParams[CallModel.CallStatusEnded] = (function (call) {
      return {
        string: 'ended'
      }
    })

    _mapStatusToParams[CallModel.CallStatusIncoming] = (function (call) {
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

    _mapStatusToParams[CallModel.CallStatusOutgoing] = (function (call) {
      return {
        component: callAction,
        handler: (function () { call.terminate() }),
        icon: 'hangup',
        string: 'outgoing'
      }
    })

    _mapStatusToParams[CallModel.CallStatusPaused] = (function (call) {
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
  }

  // ---------------------------------------------------------------------------

  Connections {
    target: model

    onRowsAboutToBeRemoved: {
      var index = calls.currentIndex

      if (index >= first && index <= last) { // Remove current call.
        if (model.rowCount() - (last - first + 1) <= 0) {
          _selectedCall = null
        } else {
          if (first === 0) {
            _selectedCall = model.data(model.index(last + 1, 0))
          } else {
            _selectedCall = model.data(model.index(0, 0))
          }
        }
      }
    }

    onRowsRemoved: {
      var index = calls.currentIndex

      // The current call has been removed.
      if (index >= first && index <= last) {
        if (model.rowCount() === 0) {
          calls.currentIndex = -1 // No calls.
        } else {
          calls.currentIndex = 0 // The first call becomes the selected call.
        }
      }

      // Update the current index of the selected call if it was after the removed calls.
      else if (last < index) {
        calls.currentIndex = index - (last - first + 1)
      }
    }

    // The last inserted outgoing element become the selected call.
    onRowsInserted: {
      for (var index = last; index >= first; index--) {
        var call = model.data(model.index(index, 0))

        if (call.isOutgoing) {
          calls.currentIndex = first
          _selectedCall = model.data(model.index(first, 0))
        }
      }
    }

    onCallRunning: {
      calls.currentIndex = index
      _selectedCall = call
    }
  }

  // ---------------------------------------------------------------------------

  Component {
    id: callAction

    ActionButton {
      icon: params.icon || 'generic_error'
      iconSize: CallsStyle.entry.iconActionSize

      onClicked: params.handler()
    }
  }

  Component {
    id: callActions

    ActionButton {
      id: button

      icon: calls.currentIndex === callId && call.status !== CallModel.CallStatusEnded
        ? 'burger_menu_light'
        : 'burger_menu'
      iconSize: CallsStyle.entry.iconMenuSize

      onClicked: menu.showMenu()

      DropDownMenu {
        id: menu

        implicitWidth: actionMenu.width
        launcher: button
        relativeTo: callControls
        relativeX: callControls.width

        ActionMenu {
          id: actionMenu

          entryHeight: CallsStyle.entry.height
          entryWidth: CallsStyle.entry.width

          Repeater {
            model: params.actions

            ActionMenuEntry {
              entryName: modelData.name

              onClicked: {
                menu.hideMenu()
                params.actions[index].handler()
              }
            }
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------

  delegate: CallControls {
    id: _callControls

    // -------------------------------------------------------------------------

    function useColorStatus () {
      return calls.currentIndex === index && $call && $call.status !== CallModel.CallStatusEnded
    }

    // -------------------------------------------------------------------------

    color: useColorStatus()
      ? CallsStyle.entry.color.selected
      : CallsStyle.entry.color.normal
    sipAddressColor: useColorStatus()
      ? CallsStyle.entry.sipAddressColor.selected
      : CallsStyle.entry.sipAddressColor.normal
    usernameColor: useColorStatus()
      ? CallsStyle.entry.usernameColor.selected
      : CallsStyle.entry.usernameColor.normal

    signIcon: {
      var params = loader.params
      return params ? 'call_sign_' + params.string : ''
    }

    sipAddress: $call.sipAddress
    width: parent.width

    onClicked: {
      _selectedCall = $call
      calls.currentIndex = index
    }

    // -------------------------------------------------------------------------

    Loader {
      id: loader

      property int callId: index
      property var call: $call
      property var callControls: _callControls
      property var params: _getParams($call)

      anchors.centerIn: parent
      sourceComponent: params.component
    }

    SequentialAnimation on color {
      loops: CallsStyle.entry.endCallAnimation.loops
      running: $call.status === CallModel.CallStatusEnded

      ColorAnimation {
        duration: CallsStyle.entry.endCallAnimation.duration
        from: CallsStyle.entry.color.normal
        to: CallsStyle.entry.endCallAnimation.blinkColor
      }

      ColorAnimation {
        duration: CallsStyle.entry.endCallAnimation.duration
        from: CallsStyle.entry.endCallAnimation.blinkColor
        to: CallsStyle.entry.color.normal
      }
    }
  }
}
