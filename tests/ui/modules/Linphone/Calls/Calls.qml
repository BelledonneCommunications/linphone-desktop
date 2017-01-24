import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

ListView {
  id: calls

  // ---------------------------------------------------------------------------

  readonly property var selectedCall: smartConnect.selectedCall

  property var _mapStatusToParams

  // ---------------------------------------------------------------------------

  function _getSignIcon (call) {
    if (call) {
      return 'call_sign_' + _mapStatusToParams[call.status].string
    }

    return ''
  }

  function _getParams (call) {
    if (call) {
      return _mapStatusToParams[call.status]
    }
  }

  // ---------------------------------------------------------------------------

  boundsBehavior: Flickable.StopAtBounds
  clip: true
  spacing: 0

  // ---------------------------------------------------------------------------

  Component.onCompleted: {
    _mapStatusToParams = {}

    _mapStatusToParams[CallModel.CallStatusConnected] = {
      actions: [{
        handler: (function (call) { call.pausedByUser = false }),
        name: qsTr('resumeCall')
      }, {
        handler: (function (call) { call.transfer() }),
        name: qsTr('transferCall')
      }, {
        handler: (function (call) { call.terminate() }),
        name: qsTr('terminateCall')
      }],
      component: callActions,
      string: 'connected'
    }

    _mapStatusToParams[CallModel.CallStatusEnded] = {
      string: 'ended'
    }

    _mapStatusToParams[CallModel.CallStatusIncoming] = {
      actions: [{
        name: qsTr('acceptAudioCall'),
        handler: (function (call) { call.accept() })
      }, {
        name: qsTr('acceptVideoCall'),
        handler: (function (call) { call.acceptWithVideo() })
      }, {
        name: qsTr('terminateCall'),
        handler: (function (call) { call.terminate() })
      }],
      component: callActions,
      string: 'incoming'
    }

    _mapStatusToParams[CallModel.CallStatusOutgoing] = {
      component: callAction,
      handler: (function (call) { call.terminate() }),
      icon: 'hangup',
      string: 'outgoing'
    }

    _mapStatusToParams[CallModel.CallStatusPaused] = {
      actions: [{
        handler: (function (call) { call.pausedByUser = true }),
        name: qsTr('pauseCall')
      }, {
        handler: (function (call) { call.transfer() }),
        name: qsTr('transferCall')
      }, {
        handler: (function (call) { call.terminate() }),
        name: qsTr('terminateCall')
      }],
      component: callActions,
      string: 'paused'
    }
  }

  // ---------------------------------------------------------------------------

  Component {
    id: callAction

    ActionButton {
      icon: params.icon
      iconSize: CallsStyle.entry.iconActionSize

      onClicked: params.handler(call)
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
                params.actions[index].handler(call)
              }
            }
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Update the current selected call and the current index.
  // ---------------------------------------------------------------------------

  SmartConnect {
    id: smartConnect

    property var selectedCall

    Component.onCompleted: {
      this.connect(model, 'rowsAboutToBeRemoved', function (_, first, last) {
        var index = calls.currentIndex

        if (index >= first && index <= last) { // Remove current call.
          if (model.rowCount() - (last - first + 1) <= 0) {
            selectedCall = null
          } else {
            if (first === 0) {
              selectedCall = model.data(model.index(last + 1, 0))
            } else {
              selectedCall = model.data(model.index(0, 0))
            }
          }
        }
      })

      this.connect(model, 'rowsRemoved', function (_, first, last) {
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
      })

      // The last inserted element become the selected call.
      this.connect(model, 'rowsInserted', function (_, first, last) {
        calls.currentIndex = first
        selectedCall = model.data(model.index(first, 0))
      })
    }
  }

  // ---------------------------------------------------------------------------

  delegate: CallControls {
    id: _callControls

    function useColorStatus () {
      return calls.currentIndex === index && $call && $call.status !== CallModel.CallStatusEnded
    }

    color: useColorStatus()
      ? CallsStyle.entry.color.selected
      : CallsStyle.entry.color.normal
    sipAddressColor: useColorStatus()
      ? CallsStyle.entry.sipAddressColor.selected
      : CallsStyle.entry.sipAddressColor.normal
    usernameColor: useColorStatus()
      ? CallsStyle.entry.usernameColor.selected
      : CallsStyle.entry.usernameColor.normal

    signIcon: _getSignIcon($call)
    sipAddress: $call.sipAddress
    width: parent.width

    Loader {
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
