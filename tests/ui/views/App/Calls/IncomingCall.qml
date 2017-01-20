import Common 1.0

import App.Styles 1.0

// ===================================================================

AbstractStartingCall {
  ActionBar {
    anchors.centerIn: parent
    iconSize: StartingCallStyle.iconSize

    ActionButton {
      icon: 'video_call_accept'
    }

    ActionButton {
      icon: 'call_accept'
    }
  }

  ActionBar {
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      rightMargin: StartingCallStyle.rightButtonsGroupMargin
    }
    iconSize: StartingCallStyle.iconSize

    ActionButton {
      icon: 'hangup'

      onClicked: call.terminate()
    }
  }
}
