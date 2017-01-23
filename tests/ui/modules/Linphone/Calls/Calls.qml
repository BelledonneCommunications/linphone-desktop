import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

ListView {
  id: calls

  // ---------------------------------------------------------------------------

  readonly property var selectedCall: currentIndex >= 0 ? model.data(model.index(currentIndex, 0)) : null

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

  // ---------------------------------------------------------------------------

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

  SmartConnect {
    Component.onCompleted: {
      this.connect(model, 'rowsAboutToBeRemoved', function (_, first, last) {
        var index = calls.currentIndex
        if (index >= first && index <= last) { // Remove current call.
          if (model.rowCount() - (last - first + 1) <= 0) {
            calls.currentIndex = -1
          } else {
            calls.currentIndex = 0
          }
        } else if (last < index) { // Remove before current call.
          calls.currentIndex = index - (last - first + 1)
        }
      })

      this.connect(model, 'rowsInserted', function (_, first, last) {
        calls.currentIndex = first
      })
    }
  }

  // ---------------------------------------------------------------------------

  delegate: CallControls {
    id: _callControls

    function useColorStatus () {
      return calls.currentIndex === index && $call.status !== CallModel.CallStatusEnded
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
