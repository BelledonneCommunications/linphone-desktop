import QtQuick 2.7

import Common 1.0

// ===================================================================

AbstractCall {
  isOutgoing: true
  callTypeLabel: isVideoCall
    ? 'OUTGOING VIDEO CALL'
    : 'OUTGOING AUDIO CALL'

  ActionBar {
    anchors {
      left: parent.left
      leftMargin: 50
      verticalCenter: parent.verticalCenter
    }
    iconSize: 40

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
    width: 130
    height: 80
    visible: isVideoCall
  }

  ActionBar {
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      rightMargin: 85
    }
    iconSize: 40

    ActionButton {
      icon: 'hangup'
    }
  }
}
