import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQml.Models
import QtQuick.Controls.Basic as Control
import Linphone
import EnumsToStringCpp
import UtilsCpp
import SettingsCpp
// =============================================================================

Item {
	id: mainItem
	property alias call: allDevices.currentCall
	property ConferenceGui conference: call && call.core.conference || null
	property var callState: call && call.core.state || undefined
	onCallStateChanged: if (callState === LinphoneEnums.CallState.End || callState === LinphoneEnums.CallState.Released) preview.visible = false
	property string localAddress: call 
		? call.conference
			? call.conference.core.me.core.sipAddress
			: call.core.localAddress
		: ""
	
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
        anchors.rightMargin: Math.round(10 * DefaultStyle.dp)
        spacing: Math.round(16 * DefaultStyle.dp)
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
            Layout.preferredWidth: Math.round(300 * DefaultStyle.dp)
            Layout.rightMargin: Math.round(10 * DefaultStyle.dp)
            Layout.bottomMargin: Math.round(10 * DefaultStyle.dp)
			visible: allDevices.count > 2 || !!mainItem.conference?.core.isScreenSharingEnabled
            //spacing: Math.round(15 * DefaultStyle.dp)	// bugged? First item has twice margins
			model: allDevices
			snapMode: ListView.SnapOneItem
			clip: true
			delegate: Item{	// Spacing workaround
				visible: $modelData && mainItem.callState != LinphoneEnums.CallState.End  && mainItem.callState != LinphoneEnums.CallState.Released
										&& ($modelData.core.address != activeSpeakerAddress || mainItem.conference?.core.isScreenSharingEnabled) || false
                height: visible ? Math.round((180 + 15) * DefaultStyle.dp) : 0
                width: Math.round(300 * DefaultStyle.dp)
				Sticker {
					previewEnabled: index == 0	// before anchors for priority initialization
					anchors.fill: parent
                    anchors.bottomMargin: Math.round(15 * DefaultStyle.dp)// Spacing
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
	Sticker {
		id: preview
		qmlName: 'P'
		previewEnabled: true
        visible: !sideStickers.visible && mainItem.callState !== LinphoneEnums.CallState.OutgoingProgress
        && mainItem.callState !== LinphoneEnums.CallState.OutgoingRinging
        && mainItem.callState !== LinphoneEnums.CallState.OutgoingInit
		onVisibleChanged: console.log(visible + " : " +allDevices.count)
        height: Math.round(180 * DefaultStyle.dp)
        width: Math.round(300 * DefaultStyle.dp)
		anchors.right: mainItem.right
		anchors.bottom: mainItem.bottom
        anchors.rightMargin: Math.round(20 * DefaultStyle.dp)
        anchors.bottomMargin: Math.round(10 * DefaultStyle.dp)
		videoEnabled: preview.visible && mainItem.call && mainItem.call.core.localVideoEnabled
		onVideoEnabledChanged: console.log("P : " +videoEnabled + " / " +visible +" / " +mainItem.call)
		property var accountObj: UtilsCpp.findLocalAccountByAddress(mainItem.localAddress)
        account: accountObj && accountObj.value || null
		call: mainItem.call
		displayAll: false
		displayPresence: false

		MovableMouseArea {
			id: previewMouseArea
			anchors.fill: parent
			movableArea: mainItem
            margin: Math.round(10 * DefaultStyle.dp)
			function resetPosition(){
				preview.anchors.right = mainItem.right
				preview.anchors.bottom = mainItem.bottom
				preview.anchors.rightMargin = previewMouseArea.margin
				preview.anchors.bottomMargin = previewMouseArea.margin
			}
			onVisibleChanged: if(!visible){
				resetPosition()
			}
			drag.target: preview
			onDraggingChanged: if(dragging) {
				preview.anchors.right = undefined
				preview.anchors.bottom = undefined
			}
			onRequestResetPosition: resetPosition()
		}
	}
}
