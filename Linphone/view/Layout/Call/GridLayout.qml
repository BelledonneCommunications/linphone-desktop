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
			Component.onCompleted: console.log("Loaded : " +allDevices)
	}
		model: participantDevices
		delegate: Item{
			id: avatarCell
			property ParticipantDeviceGui currentDevice: gridModel.participantDevices.getAt(index)
			onCurrentDeviceChanged: {
				if(index < 0) cameraView.enabled = false	// this is a delegate destruction. We need to stop camera before Qt change its currentDevice (and then, let CameraView to delete wrong renderer)
			}
			
			height: grid.cellHeight - 10
			width: grid.cellWidth - 10
			Sticker {
				id: cameraView
				visible: mainItem.callState != LinphoneEnums.CallState.End  && mainItem.callState != LinphoneEnums.CallState.Released
				anchors.fill: parent
				qmlName: 'G_'+index

				participantDevice: avatarCell.currentDevice
				previewEnabled: index == 0
				Component.onCompleted: console.log(qmlName + " is " +modelData.core.address)
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
