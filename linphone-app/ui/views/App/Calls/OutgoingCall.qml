import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

import App.Styles 1.0

// =============================================================================

AbstractStartingCall {
	showKeypad:true
	GridLayout {
		columns: parent.width < CallStyle.actionArea.lowWidth && call.videoEnabled ? 1 : 2
		rowSpacing: ActionBarStyle.spacing
		
		anchors {
			left: parent.left
			leftMargin: CallStyle.actionArea.leftButtonsGroupMargin
			verticalCenter: parent.verticalCenter
		}
		
		ActionSwitch {
			isCustom: true
			backgroundRadius: 90
			colorSet: enabled ? CallStyle.buttons.microOn : CallStyle.buttons.microOff
			enabled: !call.microMuted
			
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
			isCustom: true
			backgroundRadius: 90
			colorSet: CallStyle.buttons.hangup
			
			onClicked: call.terminate()
		}
	}
}
