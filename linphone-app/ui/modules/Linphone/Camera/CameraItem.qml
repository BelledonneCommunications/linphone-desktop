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
	property CallModel callModel
	property bool isPreview: !callModel && ( !container.currentDevice || container.currentDevice.isMe)
	property bool isFullscreen: false
	property bool hideCamera: false //callModel.pausedByUser
	property bool isPaused: false
	property bool isVideoEnabled: enabled && (!container.currentDevice || (container.currentDevice && container.currentDevice.videoEnabled))
	property bool isReady: cameraLoader.item && cameraLoader.item.isReady
	onCurrentDeviceChanged: resetActive()
	function resetActive(){
		resetTimer.resetActive()
	}
	
	Loader {
		id: cameraLoader
		property bool resetActive: false
		
		anchors.fill: parent
		
		active: container.enabled && !resetActive && container.isVideoEnabled //avatarCell.currentDevice && (avatarCell.currentDevice.videoEnabled && !conference._fullscreen)
		sourceComponent: container.isVideoEnabled && !container.isPaused? camera : null		
		
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
				call: container.callModel
				anchors.fill: parent
				isPreview: container.isPreview
				
				onRequestNewRenderer: {resetTimer.resetActive()}
				Component.onDestruction: {resetWindowId(); console.log("Destroyed Camera [" + isPreview + "] : " + camera)}
				Component.onCompleted: console.log("Completed Camera [" + isPreview + "] : " + camera)
			}
		}		
	}
}
