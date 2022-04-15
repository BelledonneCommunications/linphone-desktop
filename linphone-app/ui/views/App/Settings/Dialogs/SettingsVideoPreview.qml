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
	height: SettingsVideoPreviewStyle.height
	width: SettingsVideoPreviewStyle.width
	
	// ---------------------------------------------------------------------------
	Loader{
		id: previewLoader
		anchors.fill: parent
		sourceComponent: Item{
			anchors.fill: parent
		
			Rectangle{
				id: showArea
				anchors.fill: parent
				radius: 50
				visible:false
				color: 'red'
			}
			Rectangle{
				id: test
				anchors.fill: parent
				visible:false
				color: 'green'
			}
			CameraPreview {
				id: camera
				anchors.fill: parent
				onRequestNewRenderer: previewLoader.active = false
				visible: false
			}
			
			OpacityMask{
				anchors.fill: camera
				source: camera
				maskSource: showArea
				invert:false
	
				visible: true
				rotation: 180
			}
		}
		active: true
		onActiveChanged: {
			console.log("Active changed : " +active)
			if(!active) active = true
		}
	}
}
