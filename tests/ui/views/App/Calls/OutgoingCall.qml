import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

import App.Styles 1.0

// ===================================================================

AbstractStartingCall {
  isOutgoing: true
  callTypeLabel: isVideoCall
    ? qsTr('outgoingVideoCall')
    : qsTr('outgoingAudioCall')

  GridLayout {
    rowSpacing: ActionBarStyle.spacing
    columns: parent.width < 415 && isVideoCall ? 1 : 2

    anchors {
      left: parent.left
      leftMargin: StartingCallStyle.leftButtonsGroupMargin
      verticalCenter: parent.verticalCenter
    }

    ActionSwitch {
      icon: 'micro'
      iconSize: StartingCallStyle.iconSize

      onClicked: enabled = !enabled
    }

    ActionSwitch {
      icon: 'speaker'
      iconSize: StartingCallStyle.iconSize

      onClicked: enabled = !enabled
    }
  }

  Rectangle {
    anchors.centerIn: parent
    color: 'red'
    height: StartingCallStyle.userVideo.height
    visible: isVideoCall
    width: StartingCallStyle.userVideo.width
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
    }
  }
}
