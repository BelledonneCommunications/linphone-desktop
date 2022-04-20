import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import App.Styles 1.0
import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import LinphoneUtils 1.0

import UtilsCpp 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================
Item {
	id: container
	property ParticipantDeviceModel currentDevice
	property bool isPreview: !container.currentDevice || container.currentDevice.isMe
	property bool isFullscreen: false
	property bool hideCamera: false //callModel.pausedByUser
	property bool showCloseButton: true
	signal closeRequested()
	
	function resetActive(){
		resetTimer.resetActive()
	}
	Component {
		id: avatar
		
		IncallAvatar {
			participantDeviceModel: container.currentDevice
			height: Utils.computeAvatarSize(container, CallStyle.container.avatar.maxSize)
			width: height
		}
	}
	Loader {
		anchors.centerIn: parent
		
		active: container.currentDevice && !container.currentDevice.isMe && (!container.currentDevice.videoEnabled || container.isFullscreen)
		sourceComponent: avatar
	}
	Loader {
		id: cameraLoader
		
		property bool isVideoEnabled: !container.currentDevice || (container.currentDevice && container.currentDevice.videoEnabled)
		property bool resetActive: false
		
		property int cameraMode: isVideoEnabled ?  container.isPreview ? 1 : 2 : 0
		onCameraModeChanged: console.log(cameraMode)
		
		anchors.fill: parent
		
		active: !resetActive && isVideoEnabled //avatarCell.currentDevice && (avatarCell.currentDevice.videoEnabled && !conference._fullscreen)
		sourceComponent: cameraMode == 1 ? cameraPreview : cameraMode == 2 ? camera : null		
		
		Timer{
			id: resetTimer
			interval: 100
			repeat: false
			onTriggered: if(!cameraLoader.active){
							 cameraLoader.resetActive = false
						 }else{
							 start()	// Let some more time to propagate active event
						 }
			function resetActive(){
				start()// Do it first to avoid deleting caller while processing
				cameraLoader.resetActive = true
			}
		}
		
		Component {
			id: camera
			Camera {
				participantDeviceModel: container.currentDevice
				anchors.fill: parent
				onRequestNewRenderer: {resetTimer.resetActive()}
				Component.onDestruction: {resetWindowId()}
				Component.onCompleted: console.log("Completed Camera")
				Text{
					id: username
					anchors.right: parent.right
					anchors.left: parent.left
					anchors.bottom: parent.bottom
					anchors.margins: 10
					elide: Text.ElideRight
					maximumLineCount: 1
					text: container.currentDevice.displayName
					font.pointSize: CameraViewStyle.contactDescription.pointSize
					font.weight: CameraViewStyle.contactDescription.weight
					color: CameraViewStyle.contactDescription.color
				}/*
			DropShadow {
				anchors.fill: username
				source: username
				verticalOffset: 2
				color: "#80000000"
				radius: 1
				samples: 3
			}*/
				Glow {
					anchors.fill: username
					//spread: 1
					radius: 12
					samples: 25
					color: "#80000000"
					source: username
				}
			}
		}
		
		Component {
			id: cameraPreview
			Camera {
				anchors.fill: parent
				isPreview: true
				onRequestNewRenderer: {resetTimer.resetActive()}
				Component.onDestruction: {resetWindowId();}
				Component.onCompleted: console.log("Completed Preview")
				Rectangle{
					anchors.fill: parent
					color: 'black'
					visible: container.hideCamera
				}
				ActionButton{
					visible: container.showCloseButton
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.rightMargin: 15
					anchors.topMargin: 15
					isCustom: true
					colorSet: CameraViewStyle.closePreview
					onClicked: container.closeRequested()
				}
			}
		}
	}
}
