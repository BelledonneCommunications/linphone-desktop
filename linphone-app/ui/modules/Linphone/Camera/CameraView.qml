import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================
Item{
	id: mainItem
	property alias currentDevice: camera.currentDevice
	property alias hideCamera: camera.hideCamera
	property alias showCloseButton: camera.showCloseButton
	signal closeRequested()
	
	MouseArea{
		anchors.fill: parent
		onClicked: {camera.resetActive()}
	}
	Rectangle{
		id: showArea
		anchors.fill: parent
		radius: CameraViewStyle.radius
		visible: false
		color: 'red'
	}
	CameraItem{
		id: camera
		anchors.fill: parent
		visible: false
		onCloseRequested: mainItem.closeRequested()
	}
	OpacityMask{
		anchors.fill: parent
		source: camera
		maskSource: showArea
		invert:false
		visible: true
		
		/*	In case we need transformations.
		property Matrix4x4 mirroredRotationMatrix : Matrix4x4 {// 180 rotation + mirror
							matrix: Qt.matrix4x4(-Math.cos(Math.PI), -Math.sin(Math.PI), 0, 0,
								 Math.sin(Math.PI),  Math.cos(Math.PI), 0, camera.height,
								 0,           0,            1, 0,
								 0,           0,            0, 1)
							}
		property Matrix4x4 rotationMatrix : Matrix4x4 {// 180 rotation only
							matrix: Qt.matrix4x4(Math.cos(Math.PI), -Math.sin(Math.PI), 0, camera.width,
								 Math.sin(Math.PI),  Math.cos(Math.PI), 0, camera.height,
								 0,           0,            1, 0,
								 0,           0,            0, 1)
							}
							
		//transform: ( camera.isPreview ?  mirroredRotationMatrix : rotationMatrix)
		*/
	}
}
