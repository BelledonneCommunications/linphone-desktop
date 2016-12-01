import Common 1.0

// ===================================================================

AbstractCall {
  callTypeLabel: isVideoCall
    ? 'OUTGOING VIDEO CALL'
    : 'OUTGOING AUDIO CALL'

  ActionBar {
    anchors.centerIn: parent
    iconSize: 40

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
      rightMargin: 85
    }
    iconSize: 40

    ActionButton {
      icon: 'hangup'
    }
  }
}
