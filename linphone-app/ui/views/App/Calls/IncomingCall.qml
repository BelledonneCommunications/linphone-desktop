import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

AbstractStartingCall {
	ActionBar {
		anchors.centerIn: parent
		iconSize: CallStyle.actionArea.iconSize
		
		ActionButton {
			isCustom: true
			backgroundRadius: 90
			colorSet: CallStyle.buttons.acceptVideoCall
			visible: SettingsModel.videoAvailable
			onClicked: call.acceptWithVideo()
		}
		
		ActionButton {
			isCustom: true
			backgroundRadius: 90
			colorSet: CallStyle.buttons.acceptCall
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
			isCustom: true
			backgroundRadius: 90
			colorSet: CallStyle.buttons.hangup
			
			onClicked: call.terminate()
		}
	}
}
