import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQml.Models
import QtQuick.Controls.Basic as Control
import Linphone
import EnumsToStringCpp
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

// =============================================================================

Item {
	id: mainItem
	property alias call: allDevices.currentCall
	property ConferenceGui conference: call && call.core.conference || null
	property var callState: call && call.core.state || undefined
	property string localAddress: call 
		? call.conference
			? call.conference.core.me.core.sipAddress
			: call.core.localAddress
		: ""
	property bool sideStickersVisible: sideStickers.visible
	
	// currently speaking address (for hiding in list view)
	property string activeSpeakerAddress

	property ParticipantDeviceProxy participantDevices : ParticipantDeviceProxy {
		id: allDevices
		qmlName: "AS"
		onCountChanged: console.log("Device count changed : " +count)
		Component.onCompleted: console.log("Loaded : " +allDevices)
	}

	RowLayout{
		anchors.fill: parent
        anchors.rightMargin: Utils.getSizeWithScreenRatio(10)
        spacing: Utils.getSizeWithScreenRatio(16)
		Sticker {
			id: activeSpeakerSticker
			Layout.fillWidth: true
			Layout.fillHeight: true
			previewEnabled: false
			call: mainItem.call
			displayAll: !mainItem.conference
			participantDevice: mainItem.conference && mainItem.conference.core.activeSpeakerDevice
			property var address: participantDevice && participantDevice.core.address
			videoEnabled: (participantDevice && participantDevice.core.videoEnabled) || (!participantDevice && call && call.core.remoteVideoEnabled)
			qmlName: 'AS'
			securityBreach: !mainItem.conference && mainItem.call?.core.isMismatch || false
			displayPresence: false
			Binding {
				target: mainItem
				property: "activeSpeakerAddress"
				value: activeSpeakerSticker.address
				when: true
			}
		}
		ListView{
			id: sideStickers
			Layout.fillHeight: true
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(300)
            Layout.rightMargin: Utils.getSizeWithScreenRatio(10)
            Layout.bottomMargin: Utils.getSizeWithScreenRatio(10)
			visible: allDevices.count > 2 || !!mainItem.conference?.core.isScreenSharingEnabled
            //spacing: Utils.getSizeWithScreenRatio(15)	// bugged? First item has twice margins
			model: allDevices
			snapMode: ListView.SnapOneItem
			clip: true
			delegate: Item{	// Spacing workaround
				visible: $modelData && mainItem.callState != LinphoneEnums.CallState.End  && mainItem.callState != LinphoneEnums.CallState.Released
										&& ($modelData.core.address != activeSpeakerAddress || mainItem.conference?.core.isScreenSharingEnabled) || false
                height: visible ? Utils.getSizeWithScreenRatio(180 + 15) : 0
                width: Utils.getSizeWithScreenRatio(300)
				Sticker {
					previewEnabled: index == 0	// before anchors for priority initialization
					anchors.fill: parent
                    anchors.bottomMargin: Utils.getSizeWithScreenRatio(15)// Spacing
					qmlName: 'S_'+index
					visible: parent.visible
					participantDevice: $modelData
					displayAll: false
					displayPresence: false
					Component.onCompleted: console.log(qmlName + " is " +($modelData ? $modelData.core.address : "-"))
				}
			}
		}
	}
}
