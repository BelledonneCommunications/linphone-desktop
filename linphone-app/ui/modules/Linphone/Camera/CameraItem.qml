import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import App.Styles 1.0
import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import UtilsCpp 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================
Item {
	id: container
	property bool isCameraFromDevice: true
	property ParticipantDeviceModel currentDevice
	property CallModel callModel
	property SoundPlayer linphonePlayer
	property string qmlName
	property bool isPreview: (!callModel && !container.currentDevice) || ( container.currentDevice && container.currentDevice.isMe && container.currentDevice.isLocal)
	property bool isFullscreen: false
	property bool hideCamera: false
	property bool isPaused: false
	property bool deactivateCamera: true
	property bool isVideoEnabled: !deactivateCamera && (!callModel || callModel.videoEnabled)
									&& (!container.currentDevice || ( callModel && container.currentDevice &&
																		( (! (container.currentDevice.isMe && container.currentDevice.isLocal) && container.currentDevice.videoEnabled)
																			|| (container.currentDevice.isMe && container.currentDevice.isLocal && callModel.cameraEnabled))))

	property bool a : callModel && callModel.videoEnabled
	property bool b: container.currentDevice && container.currentDevice.videoEnabled
	property bool c: container.currentDevice && container.currentDevice.isMe && container.currentDevice.isLocal
	property bool d : callModel && callModel.cameraEnabled
	property bool isReady: cameraLoader.item && cameraLoader.item.isReady
	
	property bool hadCall : false
	onCallModelChanged: if(callModel) hadCall = true
	
	signal videoDefinitionChanged()
	
	onCurrentDeviceChanged: {if(container.isCameraFromDevice) resetActive()}
	Component.onDestruction: if(!hadCall || (hadCall && callModel) ){isVideoEnabled=false}
	function resetActive(){
		resetTimer.resetActive()
	}
	
	Loader {
		id: cameraLoader
		property bool resetActive: false
		
		anchors.fill: parent
		
		active: !resetActive && container.isVideoEnabled
		onActiveChanged: {
			console.log("QML Camera status : " + active)
		}
		
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
				qmlName: container.qmlName
				participantDeviceModel: container.currentDevice
				linphonePlayer: container.linphonePlayer
				call: container.isCameraFromDevice ? null : container.callModel
				anchors.fill: parent
				isPreview: container.isPreview
				
				onRequestNewRenderer: {resetTimer.resetActive()}
				onVideoDefinitionChanged: container.videoDefinitionChanged()
			}
		}		
	}
}
