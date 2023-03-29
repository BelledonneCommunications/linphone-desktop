import QtQuick 2.7
import QtGraphicalEffects 1.12

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
	id: dialog
	
	buttons: [
		TextButtonB {
			text: qsTr('confirm')
			
			onClicked: exit(1)
		}
	]
	
	buttonsAlignment: Qt.AlignCenter
	flat: true
	showMargins: true
	height: SettingsVideoPreviewStyle.height
	width: SettingsVideoPreviewStyle.width
	
	// ---------------------------------------------------------------------------
	Item{
		anchors.fill: parent
		CameraView{
			id: previewLoader
			anchors.centerIn: parent
			height: parent.height
			width: height
			qmlName: 'SettingsVideo'
			showCloseButton: false
		}
	}
}
