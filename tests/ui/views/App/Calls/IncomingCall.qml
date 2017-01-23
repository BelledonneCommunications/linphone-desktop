import Common 1.0

import App.Styles 1.0

// =============================================================================

AbstractStartingCall {
  ActionBar {
    anchors.centerIn: parent
    iconSize: CallStyle.iconSize

    ActionButton {
      icon: 'video_call_accept'

      onClicked: call.acceptWithVideo()
    }

    ActionButton {
      icon: 'call_accept'

      onClicked: call.accept()
    }
  }

  ActionBar {
    anchors {
      right: parent.right
      rightMargin: CallStyle.rightButtonsGroupMargin
      verticalCenter: parent.verticalCenter
    }
    iconSize: CallStyle.iconSize

    ActionButton {
      icon: 'hangup'

      onClicked: call.terminate()
    }
  }
}
