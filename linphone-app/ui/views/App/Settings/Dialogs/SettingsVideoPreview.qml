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
	Item{
		anchors.fill: parent
		CameraView{
			id: previewLoader
			anchors.centerIn: parent
			height: parent.height
			width: height
		}
	}
	
	
	/*
	Loader{
		id: previewLoader
		anchors.fill: parent
		sourceComponent: Item{
			anchors.fill: parent
			Rectangle{
				id: showArea
				anchors.fill: parent
				radius: 10
				visible:false
				color: 'red'
			}
			CameraPreview {
				id: camera
				anchors.fill: parent
				onRequestNewRenderer: {previewLoader.active = false;previewLoader.active = true}
				visible: false
			}
			
			OpacityMask{
				anchors.fill: parent
				source: camera
				maskSource: showArea
				transform: Matrix4x4 {// 180 rotation + mirror
					matrix: Qt.matrix4x4(-Math.cos(Math.PI), -Math.sin(Math.PI), 0, 0,
                             Math.sin(Math.PI),  Math.cos(Math.PI), 0, camera.height,
                             0,           0,            1, 0,
                             0,           0,            0, 1)
				}
			}
		}
		active: true
		onActiveChanged: {
			console.log("Active changed : " +active)
			if(!active) active = true
		}
	}*/
}
