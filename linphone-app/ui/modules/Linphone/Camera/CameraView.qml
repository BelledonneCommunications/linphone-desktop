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
Item{
	id: mainItem
	property alias currentDevice: camera.currentDevice
	property alias callModel: camera.callModel
	property alias linphonePlayer : camera.linphonePlayer
	property alias hideCamera: camera.hideCamera
	property alias isPaused: camera.isPaused
	property alias isPreview: camera.isPreview
	property alias isFullscreen: camera.isFullscreen
	property alias isCameraFromDevice: camera.isCameraFromDevice
	property alias qmlName: camera.qmlName
	property bool showCloseButton: false
	property bool showActiveSpeakerOverlay: true
	property color color : camera.isReady ?  CameraViewStyle.cameraBackgroundColor.color : CameraViewStyle.outBackgroundColor.color
	property real avatarRatio : 2/3
	
	signal closeRequested()
	signal videoDefinitionChanged()
	
	MouseArea{
		anchors.fill: parent
		onClicked: camera.resetActive()
	}
	 RectangularGlow {
        id: effect
        anchors.fill: backgroundArea
        glowRadius: 4
        spread: 0.9
        color: CameraViewStyle.border.colorModel.color
        cornerRadius: backgroundArea.radius + glowRadius
        visible: mainItem.showActiveSpeakerOverlay && mainItem.currentDevice && mainItem.currentDevice.isSpeaking
    }
	Rectangle {
        id: backgroundArea
        color: mainItem.color
        anchors.fill: parent
        radius: CameraViewStyle.radius
        Component {
			id: avatar
			
			IncallAvatar {
				participantDeviceModel: mainItem.currentDevice
				call: participantDeviceModel ? undefined : camera.callModel
				height: Utils.computeAvatarSize(backgroundArea, CallStyle.container.avatar.maxSize, avatarRatio)
				width: height
				backgroundColor: CameraViewStyle.inAvatarBackgroundColor
			}
		}
		Loader {
			anchors.centerIn: parent
			
			active:  (mainItem.callModel || mainItem.currentDevice) && !camera.isReady
			sourceComponent: avatar
		}
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
		anchors.centerIn: parent
		anchors.fill: parent
		visible: false
		onVideoDefinitionChanged: mainItem.videoDefinitionChanged()
		deactivateCamera: false
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
	
	Rectangle{
		id: hideView
		anchors.fill: parent
		color: CameraViewStyle.pauseView.backgroundColor.color
		radius: CameraViewStyle.radius
		visible: mainItem.isPaused
		Rectangle{
			anchors.centerIn: parent
			height: CameraViewStyle.pauseView.button.iconSize
			width: height
			radius: width/2
			color: CameraViewStyle.pauseView.button.backgroundNormalColor.color
			Icon{
				anchors.centerIn: parent
				icon: CameraViewStyle.pauseView.button.icon
				overwriteColor: CameraViewStyle.pauseView.button.foregroundNormalColor.color
				iconSize: CameraViewStyle.pauseView.button.iconSize
			}
		}
	}
	Text{
		id: username
		visible: mainItem.currentDevice
		anchors.right: parent.right
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		anchors.margins: 10
		elide: Text.ElideRight
		maximumLineCount: 1
		text: mainItem.currentDevice && mainItem.currentDevice.displayName + (mainItem.isPaused ? ' (en pause)' : '')
		font.pointSize: CameraViewStyle.contactDescription.pointSize
		font.weight: CameraViewStyle.contactDescription.weight
		color: CameraViewStyle.contactDescription.colorModel.color
	}
	Glow {
		anchors.fill: username
		//spread: 1
		radius: 12
		samples: 25
		color: "#80000000"
		source: username
	}
	ActionButton{
		visible: mainItem.showCloseButton && camera.isPreview && mainItem.callModel && mainItem.callModel.videoEnabled
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.rightMargin: 5
		anchors.topMargin: 5
		isCustom: true
		colorSet: CameraViewStyle.closePreview
		onClicked: mainItem.closeRequested()
	}
	Rectangle{
		visible: mainItem.currentDevice && mainItem.currentDevice.isMuted
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.rightMargin: 15
		anchors.topMargin: 15
		height: CameraViewStyle.isMuted.button.iconSize
		width: height
		radius: width/2
		color: CameraViewStyle.isMuted.button.backgroundNormalColor.color
		Icon{
			anchors.centerIn: parent
			icon: CameraViewStyle.isMuted.button.icon
			overwriteColor: CameraViewStyle.isMuted.button.foregroundNormalColor.color
			iconSize: CameraViewStyle.isMuted.button.iconSize
		}
	}
}
