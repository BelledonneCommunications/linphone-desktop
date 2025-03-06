import QtQuick
import QtQuick.Layouts
import QtQml.Models

import Linphone
import UtilsCpp

// =============================================================================

Mosaic {
	id: grid
	property alias call: allDevices.currentCall
	property ConferenceGui conference: call && call.core.conference || null
	property bool videoEnabled: true
	property int participantCount: gridModel.count
	
	margins: 0
	// On grid view, we limit the quality if there are enough participants// The vga mode has been activated from the factory rc
	//onParticipantCountChanged: participantCount > ConstantsCpp.maxMosaicParticipants ? SettingsModel.setLimitedMosaicQuality() : SettingsModel.setHighMosaicQuality()
	delegateModel: DelegateModel{
		id: gridModel
		property ParticipantDeviceProxy participantDevices : ParticipantDeviceProxy {
			id: allDevices
			qmlName: "G"
			Component.onCompleted: console.log("Loaded : " +allDevices + " = " +allDevices.count)
		}
		property AccountProxy  accounts: AccountProxy {
			id: accountProxy
			sourceModel: AppCpp.accounts
		}
		model: grid.call && grid.call.core.isConference ? participantDevices: [0,1]
		delegate: Item{
			id: avatarCell
			property ParticipantDeviceGui currentDevice: index >= 0 &&  grid.call && grid.call.core.isConference ? $modelData : null
			onCurrentDeviceChanged: {
				if(index < 0) cameraView.enabled = false	// this is a delegate destruction. We need to stop camera before Qt change its currentDevice (and then, let CameraView to delete wrong renderer)
			}
			
            height: grid.cellHeight - Math.round(10 * DefaultStyle.dp)
            width: grid.cellWidth - Math.round(10 * DefaultStyle.dp)
			Sticker {
				id: cameraView
				previewEnabled: index == 0
				visible: mainItem.callState != LinphoneEnums.CallState.End  && mainItem.callState != LinphoneEnums.CallState.Released
				anchors.fill: parent
				qmlName: 'G_'+index
				call: grid.call && !grid.call.core.isConference ? grid.call : null
				property var accountObj: UtilsCpp.findLocalAccountByAddress(mainItem.localAddress)
				account: (index == 0 && accountObj) ? accountObj.value : null
				displayAll: false
				displayPresence: false
				participantDevice: avatarCell.currentDevice
				Component.onCompleted: console.log(qmlName + " is " +(call ? call.core.remoteAddress : currentDevice ? currentDevice.core.address : 'addr_NotDefined'))
			}
		}
	}
}
