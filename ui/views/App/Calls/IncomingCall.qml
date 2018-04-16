import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

AbstractStartingCall {
  ActionBar {
    id: actionBar

    anchors.centerIn: parent
    iconSize: CallStyle.actionArea.iconSize

    Loader {
      active: SettingsModel.videoSupported
      sourceComponent: ActionButton {
        icon: 'video_call_accept'
        iconSize: actionBar.iconSize

        onClicked: call.acceptWithVideo()
      }
    }

    ActionButton {
      icon: 'call_accept'

      onClicked: call.accept()
    }
  }

  ActionBar {
    anchors {
      right: parent.right
      rightMargin: CallStyle.actionArea.rightButtonsGroupMargin
      verticalCenter: parent.verticalCenter
    }
    iconSize: CallStyle.actionArea.iconSize

    ActionButton {
      icon: 'hangup'

      onClicked: call.terminate()
    }
  }
}
