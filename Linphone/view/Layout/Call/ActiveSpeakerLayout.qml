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
	property int participantDeviceCount: allDevices.count
	onParticipantDeviceCountChanged: {
		setUpMainItem()
	}
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
	
	Component.onCompleted: setUpMainItem()
	onVisibleChanged: if (visible) setUpMainItem()

	function setUpMainItem() {
		if (mainItem.conference && mainItem.participantDeviceCount <= 1) {
			mainStackView.replace(waitingForOthersComponent)
		} else {
			mainStackView.replace(activeSpeakerComp)
		}
	}

	RowLayout{
		anchors.fill: parent
		anchors.rightMargin: 10 * DefaultStyle.dp
		spacing: 16 * DefaultStyle.dp
		
		Control.StackView {
			id: mainStackView
			// initialItem: waitingForOthersComponent
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
		Component {
			id: waitingForOthersComponent
			Rectangle {
				color: DefaultStyle.grey_600
				radius: 15 * DefaultStyle.dp
				ColumnLayout {
					anchors.centerIn: parent
					spacing: 22 * DefaultStyle.dp
					width: waitText.implicitWidth
					Text {
						id: waitText
						text: qsTr("Waiting for other participants...")
						Layout.preferredHeight: 67 * DefaultStyle.dp
						Layout.alignment: Qt.AlignHCenter
						horizontalAlignment: Text.AlignHCenter
						color: DefaultStyle.grey_0
						font {
							pixelSize: 30 * DefaultStyle.dp
							weight: 300 * DefaultStyle.dp
						}
					}
					Item {
						Layout.fillWidth: true
						Button {
							color: "transparent"
							borderColor: DefaultStyle.main2_400
							pressedColor: DefaultStyle.main2_500main
							icon.source: AppIcons.shareNetwork
							contentImageColor: DefaultStyle.main2_400
							text: qsTr("Share invitation")
							topPadding: 11 * DefaultStyle.dp
							bottomPadding: 11 * DefaultStyle.dp
							leftPadding: 20 * DefaultStyle.dp
							rightPadding: 20 * DefaultStyle.dp
							anchors.centerIn: parent
							textColor: DefaultStyle.main2_400
							onClicked: {
								if (mainItem.conference) {
									UtilsCpp.copyToClipboard(mainItem.call.core.peerAddress)
									showInformationPopup(qsTr("Copié"), qsTr("Le lien de la réunion a été copié dans le presse-papier"), true)
								}
							}
						}
					}
				}
			}
		}
		Component {
			id: activeSpeakerComp
			Sticker {
				id: activeSpeakerSticker
				previewEnabled: false
				call: mainItem.call
				width: mainStackView.width
				height: mainStackView.height
				participantDevice: mainItem.conference && mainItem.conference.core.activeSpeaker
				property var address: participantDevice && participantDevice.core.address
				videoEnabled: (participantDevice && participantDevice.core.videoEnabled) || (!participantDevice && call && call.core.remoteVideoEnabled)
				qmlName: 'AS'
				displayPresence: false
				Binding {
					target: mainItem
					property: "activeSpeakerAddress"
					value: activeSpeakerSticker.address
					when: true
				}
			}
		}
		ListView{
			id: sideStickers
			Layout.fillHeight: true
			Layout.preferredWidth: 300 * DefaultStyle.dp
			Layout.rightMargin: 10 * DefaultStyle.dp
			Layout.bottomMargin: 10 * DefaultStyle.dp
			visible: allDevices.count > 2 || !!mainItem.conference?.core.isScreenSharingEnabled
			//spacing: 15 * DefaultStyle.dp	// bugged? First item has twice margins
			model: allDevices
			snapMode: ListView.SnapOneItem
			clip: true
			delegate: Item{	// Spacing workaround
				visible: $modelData && mainItem.callState != LinphoneEnums.CallState.End  && mainItem.callState != LinphoneEnums.CallState.Released
										&& ($modelData.core.address != activeSpeakerAddress || mainItem.conference?.core.isScreenSharingEnabled) || false
				height: visible ? (180 + 15) * DefaultStyle.dp : 0
				width: 300 * DefaultStyle.dp
				Sticker {
					previewEnabled: index == 0	// before anchors for priority initialization
					anchors.fill: parent
					anchors.bottomMargin: 15 * DefaultStyle.dp// Spacing
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
		visible: !sideStickers.visible
		onVisibleChanged: console.log(visible + " : " +allDevices.count)
		height: 180 * DefaultStyle.dp
		width: 300 * DefaultStyle.dp
		anchors.right: mainItem.right
		anchors.bottom: mainItem.bottom
		anchors.rightMargin: 20 * DefaultStyle.dp
		anchors.bottomMargin: 10 * DefaultStyle.dp
		videoEnabled: preview.visible && mainItem.call && mainItem.call.core.localVideoEnabled
		onVideoEnabledChanged: console.log("P : " +videoEnabled + " / " +visible +" / " +mainItem.call)
		property AccountProxy accounts: AccountProxy{id: accountProxy}
		account: accountProxy.findAccountByAddress(mainItem.localAddress)
		call: mainItem.call
		displayAll: false
		displayPresence: false

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

