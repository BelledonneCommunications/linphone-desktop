import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQml.Models
import QtQuick.Controls as Control
import Linphone
import EnumsToStringCpp 1.0
import UtilsCpp 1.0
import SettingsCpp 1.0
// =============================================================================

Item{
	id: mainItem
	property alias call: allDevices.currentCall
	property ConferenceGui conference: call && call.core.conference || null
	property var callState: call && call.core.state || undefined
	
	property ParticipantDeviceProxy participantDevices : ParticipantDeviceProxy {
			id: allDevices
			qmlName: "AS"
			onCountChanged: console.log("Device count changed : " +count)
			Component.onCompleted: console.log("Loaded : " +allDevices)
	}
	onCallChanged: {
		waitingTime.seconds = 0
		waitingTimer.restart()
		console.log("call changed", call, waitingTime.seconds)
	}
	RowLayout{
		anchors.fill: parent
		anchors.rightMargin: 10 * DefaultStyle.dp
		spacing: 16 * DefaultStyle.dp
		
		Sticker {
			id: activeSpeakerSticker
			previewEnabled: false
			Layout.fillWidth: true
			Layout.fillHeight: true
			call: mainItem.call
			participantDevice: mainItem.conference && mainItem.conference.core.activeSpeaker
			property var address: participantDevice && participantDevice.core.address
			videoEnabled: (participantDevice && participantDevice.core.videoEnabled) || (!participantDevice && call && call.core.remoteVideoEnabled)
			qmlName: 'AS'
	
			Timer {
				id: waitingTimer
				interval: 1000
				repeat: true
				onTriggered: waitingTime.seconds += 1
			}
			ColumnLayout {
				id: waitingConnection
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				anchors.topMargin: 30 * DefaultStyle.dp
				spacing: 0
				visible: mainItem.callState === LinphoneEnums.CallState.OutgoingInit
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingProgress
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingRinging
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingEarlyMedia
						|| mainItem.callState === LinphoneEnums.CallState.IncomingReceived
				BusyIndicator {
					indicatorColor: DefaultStyle.main2_100
					Layout.alignment: Qt.AlignHCenter
					indicatorHeight: 30 * DefaultStyle.dp
					indicatorWidth: 30 * DefaultStyle.dp
				}
				Text {
					id: waitingTime
					property int seconds
					text: UtilsCpp.formatElapsedTime(seconds)
					color: DefaultStyle.grey_0
					Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					font {
						pixelSize: 30 * DefaultStyle.dp
						weight: 300 * DefaultStyle.dp
					}
					Component.onCompleted: {
						waitingTimer.restart()
					}
				}
			}
		}
		ListView{
			Layout.fillHeight: true
			Layout.preferredWidth: 300 * DefaultStyle.dp
			Layout.rightMargin: 10 * DefaultStyle.dp
			Layout.bottomMargin: 10 * DefaultStyle.dp
			visible: allDevices.count > 2
			//spacing: 15 * DefaultStyle.dp	// bugged? First item has twice margins
			model: allDevices
			snapMode: ListView.SnapOneItem
			clip: true
			delegate: Item{	// Spacing workaround
				visible: $modelData && mainItem.callState != LinphoneEnums.CallState.End  && mainItem.callState != LinphoneEnums.CallState.Released
										&& $modelData.core.address != activeSpeakerSticker.address || false
				height: visible ? (180 + 15) * DefaultStyle.dp : 0
				width: 300 * DefaultStyle.dp
				Sticker {
					previewEnabled: index == 0	// before anchors for priority initialization
					anchors.fill: parent
					anchors.bottomMargin: 15 * DefaultStyle.dp// Spacing
					qmlName: 'S_'+index
					visible: parent.visible
					participantDevice: $modelData
					Component.onCompleted: console.log(qmlName + " is " +($modelData ? $modelData.core.address : "-"))
				}
			}
		}
	}
	Sticker {
		id: preview
		qmlName: 'P'
		previewEnabled: true
		visible: mainItem.call && allDevices.count <= 2 && !waitingConnection.visible
		onVisibleChanged: console.log(visible + " : " +allDevices.count)
		height: 180 * DefaultStyle.dp
		width: 300 * DefaultStyle.dp
		anchors.right: mainItem.right
		anchors.bottom: mainItem.bottom
		anchors.rightMargin: 20 * DefaultStyle.dp
		anchors.bottomMargin: 10 * DefaultStyle.dp
		//participantDevice: allDevices.me
		videoEnabled: preview.visible && mainItem.call && mainItem.call.core.localVideoEnabled
		onVideoEnabledChanged: console.log("P : " +videoEnabled + " / " +visible +" / " +mainItem.call)
		property AccountProxy accounts: AccountProxy{id: accountProxy}
		account: accountProxy.defaultAccount
		call: mainItem.call

		MovableMouseArea {
			id: previewMouseArea
			anchors.fill: parent
			movableArea: mainItem
			margin: 10 * DefaultStyle.dp
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

