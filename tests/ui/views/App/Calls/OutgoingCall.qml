import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

import App.Styles 1.0

// =============================================================================

AbstractStartingCall {
  GridLayout {
    columns: parent.width < StartingCallStyle.low && call.videoOutputEnabled ? 1 : 2
    rowSpacing: ActionBarStyle.spacing

    anchors {
      left: parent.left
      leftMargin: StartingCallStyle.leftButtonsGroupMargin
      verticalCenter: parent.verticalCenter
    }

    ActionSwitch {
      enabled: !call.microMuted
      icon: 'micro'
      iconSize: StartingCallStyle.iconSize

      onClicked: call.microMuted = enabled
    }

    ActionSwitch {
      icon: 'speaker'
      iconSize: StartingCallStyle.iconSize

      onClicked: enabled = !enabled
    }
  }

  Item {
    anchors.centerIn: parent
    height: StartingCallStyle.userVideo.height
    width: StartingCallStyle.userVideo.width

    visible: call.videoOutputEnabled
  }

  ActionBar {
    anchors {
      right: parent.right
      rightMargin: StartingCallStyle.rightButtonsGroupMargin
      verticalCenter: parent.verticalCenter
    }
    iconSize: StartingCallStyle.iconSize

    ActionButton {
      icon: 'hangup'

      onClicked: call.terminate()
    }
  }
}
