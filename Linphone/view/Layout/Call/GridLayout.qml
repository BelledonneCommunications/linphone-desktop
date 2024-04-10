import QtQuick
import QtQuick.Layouts
import QtQml.Models

import Linphone

// =============================================================================

Mosaic {
	id: grid
	property alias call: allDevices.currentCall
	property bool cameraEnabled: true
	property int participantCount: gridModel.count
	
	// On grid view, we limit the quality if there are enough participants// The vga mode has been activated from the factory rc
	//onParticipantCountChanged: participantCount > ConstantsCpp.maxMosaicParticipants ? SettingsModel.setLimitedMosaicQuality() : SettingsModel.setHighMosaicQuality()
	delegateModel: DelegateModel{
		id: gridModel
		property ParticipantDeviceProxy participantDevices : ParticipantDeviceProxy {
			id: allDevices
			qmlName: "G"
			Component.onCompleted: console.log("Loaded : " +allDevices + " = " +allDevices.count)
	}
		model: grid.call.core.isConference ? participantDevices: [0,1]
		delegate: Item{
			id: avatarCell
			property ParticipantDeviceGui currentDevice: grid.call.core.isConference ? gridModel.participantDevices.getAt(index) : null
			onCurrentDeviceChanged: {
				if(index < 0) cameraView.enabled = false	// this is a delegate destruction. We need to stop camera before Qt change its currentDevice (and then, let CameraView to delete wrong renderer)
			}
			
			height: grid.cellHeight - 10
			width: grid.cellWidth - 10
			Sticker {
				id: cameraView
				previewEnabled: index == 0
				visible: mainItem.callState != LinphoneEnums.CallState.End  && mainItem.callState != LinphoneEnums.CallState.Released
				anchors.fill: parent
				qmlName: 'G_'+index
				call: !grid.call.core.isConference ? grid.call : null
				
				participantDevice: avatarCell.currentDevice
				Component.onCompleted: console.log(qmlName + " is " +(call ? call.core.peerAddress : currentDevice ? currentDevice.core.address : 'addr_NotDefined'))
			}
			/*
			Sticker{
				id: cameraView
				anchors.fill: parent
				
				cameraQmlName: 'G_'+index
				callModel: index >= 0 ? allDevices.callModel : null	// do this before to prioritize changing call on remove
				deactivateCamera: index <0 || !grid.cameraEnabled || grid.callModel.pausedByUser
				currentDevice: gridModel.participantDevices.getAt(index)
				
				isCameraFromDevice: true
				isPaused: !isPreview && avatarCell.currentDevice && avatarCell.currentDevice.isPaused
				showCloseButton: false
				showCustomButton:  false
				avatarStickerBackgroundColor: isPreview? IncallStyle.container.avatar.stickerPreviewBackgroundColor.color : IncallStyle.container.avatar.stickerBackgroundColor.color
				avatarBackgroundColor: IncallStyle.container.avatar.backgroundColor.color
				
				//onCloseRequested: participantDevices.showMe = false
			}*/
		}
	}
}
