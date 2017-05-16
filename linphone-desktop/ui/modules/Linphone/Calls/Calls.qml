import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import 'Calls.js' as Logic

// =============================================================================

ListView {
  id: calls

  // ---------------------------------------------------------------------------

  readonly property var selectedCall: calls._selectedCall

  property var _selectedCall

  // ---------------------------------------------------------------------------

  boundsBehavior: Flickable.StopAtBounds
  clip: true
  spacing: 0

  // ---------------------------------------------------------------------------

  onCountChanged: Logic.handleCountChanged(count)

  Connections {
    target: model

    onCallRunning: Logic.handleCallRunning(index, callModel)
    onRowsAboutToBeRemoved: Logic.handleRowsAboutToBeRemoved(parent, first, last)
    onRowsInserted: Logic.handleRowsInserted(parent, first, last)
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

      onClicked: popup.show()

      Popup {
        id: popup

        implicitWidth: actionMenu.width
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
                popup.hide()
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
      if ($call.status !== CallModel.CallStatusEnded) {
        _selectedCall = $call
        calls.currentIndex = index
      }
    }

    // -------------------------------------------------------------------------

    Loader {
      id: loader

      readonly property int callId: index

      readonly property var call: $call
      readonly property var callControls: _callControls
      readonly property var params: Logic.getParams($call)

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
