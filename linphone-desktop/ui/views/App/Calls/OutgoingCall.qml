import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

import App.Styles 1.0

// =============================================================================

AbstractStartingCall {
  GridLayout {
    columns: parent.width < CallStyle.actionArea.lowWidth && call.videoEnabled ? 1 : 2
    rowSpacing: ActionBarStyle.spacing

    anchors {
      left: parent.left
      leftMargin: CallStyle.actionArea.leftButtonsGroupMargin
      verticalCenter: parent.verticalCenter
    }

    ActionSwitch {
      enabled: !call.microMuted
      icon: 'micro'
      iconSize: CallStyle.actionArea.iconSize

      onClicked: call.microMuted = enabled
    }
  }

  Item {
    anchors.centerIn: parent
    height: CallStyle.actionArea.userVideo.height
    width: CallStyle.actionArea.userVideo.width

    visible: call.videoEnabled
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
