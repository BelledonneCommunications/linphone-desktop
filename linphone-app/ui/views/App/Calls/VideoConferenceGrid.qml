import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0

import UtilsCpp 1.0

import App.Styles 1.0


// Temp
import 'Incall.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Mosaic {
	id: grid
	property alias callModel: participantDevices.callModel
	property bool cameraEnabled: true
	property int participantCount: gridModel.count
	squaredDisplay: true

	delegateModel: DelegateModel{
		id: gridModel
		property ParticipantDeviceProxyModel participantDevices : ParticipantDeviceProxyModel {
			id: participantDevices
			property bool cameraEnabled: callModel && callModel.cameraEnabled
			onCameraEnabledChanged: showMe = cameraEnabled	// Do it on changed to ignore hard bindings (that can be override)
			showMe: true
		}
		model: participantDevices
		delegate: Item{
			id: avatarCell
			property ParticipantDeviceModel currentDevice: gridModel.participantDevices.getAt(index)
			onCurrentDeviceChanged: {
				if(index < 0) cameraView.enabled = false	// this is a delegate destruction. We need to stop camera before Qt change its currentDevice (and then, let CameraView to delete wrong renderer)
			}
			
			height: grid.cellHeight - 10
			width: grid.cellWidth - 10
			
			CameraView{
				id: cameraView
				enabled: index >=0 && grid.cameraEnabled
				anchors.fill: parent
				currentDevice: avatarCell.currentDevice
				callModel: participantDevices.callModel
				isCameraFromDevice: true
				isPaused: grid.callModel.pausedByUser || avatarCell.currentDevice && avatarCell.currentDevice.isPaused
				onCloseRequested: participantDevices.showMe = false
				//showCloseButton: participantDevices.count > 1
			}
		}
	}
}
