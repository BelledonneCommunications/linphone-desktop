import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

// ===================================================================

AbstractStartingCall {
  isOutgoing: true
  callTypeLabel: isVideoCall
    ? qsTr('outgoingVideoCall')
    : qsTr('outgoingAudioCall')

  ActionBar {
    anchors {
      left: parent.left
      leftMargin: StartingCallStyle.leftButtonsGroupMargin
      verticalCenter: parent.verticalCenter
    }
    iconSize: StartingCallStyle.iconSize

    ActionSwitch {
      icon: 'micro'
      onClicked: enabled = !enabled
    }

    ActionSwitch {
      icon: 'speaker'
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
