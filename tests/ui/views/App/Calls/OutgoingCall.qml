import Common 1.0

// ===================================================================

AbstractCall {
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
    }

    ActionSwitch {
      icon: 'speaker'
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
