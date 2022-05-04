import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import UtilsCpp 1.0

import App.Styles 1.0


// Temp
import 'Incall.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Mosaic {
	id: grid
	property alias callModel: participantDevices.callModel
	property int participantCount: gridModel.count
	anchors.fill: parent
	squaredDisplay: true
	
	function setTestMode(){
		grid.clear()
		gridModel.model = gridModel.defaultList
		for(var i = 0 ; i < 5 ; ++i)
			grid.add({color:  '#'+ Math.floor(Math.random()*255).toString(16)
							  +Math.floor(Math.random()*255).toString(16)
							  +Math.floor(Math.random()*255).toString(16)})
		console.log("Setting test mode : count=" + gridModel.defaultList.count)
	}
	function setParticipantDevicesMode(){
		console.log("Setting participant mode : count=" + gridModel.participantDevices.count)
		grid.clear()
		gridModel.model = gridModel.participantDevices
	}
	
	delegateModel: DelegateModel{
		id: gridModel
		property ParticipantDeviceProxyModel participantDevices : ParticipantDeviceProxyModel {
			id: participantDevices
			property bool cameraEnabled: callModel && callModel.cameraEnabled
			onCameraEnabledChanged: showMe = cameraEnabled	// Do it on changed to ignore hard bindings (that can be override)
			showMe: true
		}
		model: participantDevices
		onCountChanged: {console.log("Delegate count = "+count+"/"+participantDevices.count)}
		delegate: Item{
			id: avatarCell
			property ParticipantDeviceModel currentDevice: gridModel.participantDevices.getAt(index)
			onCurrentDeviceChanged: {
				console.log("currentDevice changed: " +currentDevice+"/"+cameraView.currentDevice + (currentDevice?", me:"+currentDevice.isMe:'')+" ["+index+"]")
				if(index < 0) cameraView.enabled = false	// this is a delegate destruction. We need to stop camera before Qt change its currentDevice (and then, let CameraView to delete wrong renderer)
				
			}
			//color: 'black' /*!conference.callModel && gridModel.defaultList.get(index).color ? gridModel.defaultList.get(index).color : */
			//color: gridModel.model.get(index) && gridModel.model.get(index).color ? gridModel.model.get(index).color : ''	// modelIndex is a custom index because by Mosaic modelisation, it is not accessible.
			//color:  $modelData.color ? $modelData.color : ''
			height: grid.cellHeight - 10
			width: grid.cellWidth - 10
			Component.onCompleted: {
				console.log("Completed: ["+index+"] " +(currentDevice?currentDevice.peerAddress+", isMe:"+currentDevice.isMe : '') )
			}
			
			CameraView{
				id: cameraView
				enabled: index >=0
				anchors.fill: parent
				currentDevice: avatarCell.currentDevice
				callModel: participantDevices.callModel
				isCameraFromDevice: true
				isPaused: grid.callModel.pausedByUser || avatarCell.currentDevice && avatarCell.currentDevice.isPaused //callModel.pausedByUser
				onCloseRequested: participantDevices.showMe = false //grid.remove( index)
				//color: 'black'
			}
		}
	}
}
