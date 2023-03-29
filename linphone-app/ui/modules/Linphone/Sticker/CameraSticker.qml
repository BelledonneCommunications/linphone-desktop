import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import App.Styles 1.0
import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================
DecorationSticker{
	id: mainItem
	property alias currentDevice: camera.currentDevice
	property alias callModel: camera.callModel
	property alias deactivateCamera: camera.deactivateCamera
	property alias hideCamera: camera.hideCamera
	property alias isPaused: camera.isPaused
	property alias isPreview: camera.isPreview
	property alias isFullscreen: camera.isFullscreen
	property alias isCameraFromDevice: camera.isCameraFromDevice
	property alias isReady: camera.isReady
	property alias isVideoEnabled: camera.isVideoEnabled
	property alias cameraQmlName: camera.qmlName
	property bool showCloseButton: false
	property bool showActiveSpeakerOverlay: true
	property color color : CameraStickerStyle.cameraBackgroundColor.color
	
	property alias showCustomButton: mainItem._showCustomButton
	property alias customButtonToggled: mainItem._customButtonToggled
	property alias customButtonColorSet: mainItem._customButtonColorSet
	
	signal videoDefinitionChanged()
	onBackgroundClicked: camera.resetActive()
	onDeactivateCameraChanged: if( deactivateCamera) camera.resetActive()
	
	function resetCamera(){
		camera.resetActive();
	}
	
	_currentDevice: currentDevice
	_callModel: callModel
	_isPaused: isPaused
	_isPreview: isPreview
	_showCloseButton: showCloseButton
	_showActiveSpeakerOverlay: showActiveSpeakerOverlay
	
	clip:false
	radius: CameraStickerStyle.radius
	
	_content: Rectangle{
		anchors.fill: parent
		color: mainItem.color
		radius: CameraStickerStyle.radius
		
		Rectangle{
			id: showArea
			
			anchors.fill: parent
			radius: mainItem.radius
			visible: false
			color: 'red'
		}
		CameraItem{
			id: camera
			callModel: mainItem.callModel
			
			anchors.centerIn: parent
			anchors.fill: parent
			visible: false
			onVideoDefinitionChanged: mainItem.videoDefinitionChanged()
		}
		OpacityMask{
			id: renderedCamera
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
}
