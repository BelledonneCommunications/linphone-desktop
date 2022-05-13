import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0

import Common.Styles 1.0
import App.Styles 1.0

// =============================================================================

Rectangle {
	id: mainItem
	color: WaitingRoomStyle.backgroundColor
	property ConferenceInfoModel conferenceInfoModel

	signal cancel()
	
	function close(){
		previewLoader.enabled = false
	}
	function open(){
	}
	
	ColumnLayout {
		anchors.fill: parent
		Text{
			Layout.alignment: Qt.AlignCenter
			Layout.preferredHeight: 60
			Layout.topMargin: 15
			text: conferenceInfoModel.subject
			color: WaitingRoomStyle.title.color
			font.pointSize:  WaitingRoomStyle.title.pointSize
			horizontalAlignment: Qt.AlignCenter
		}
		RowLayout{
			id: loader
			Layout.fillWidth: true
			Layout.fillHeight: true
			Item{
				Layout.fillHeight: true
				Layout.fillWidth: true
				CameraView{
					id: previewLoader
					showCloseButton: false
					anchors.centerIn: parent
					height: Math.min( parent.height, parent.width)
					width : height
					ActionButton{
						anchors.top: parent.top
						anchors.right: parent.right
						anchors.topMargin: 10
						anchors.rightMargin: 10
						isCustom: true
						backgroundRadius: width/2
						colorSet: WaitingRoomStyle.buttons.options
						toggled: mediaMenu.visible
						onClicked: mediaMenu.visible = !mediaMenu.visible
					}
				}
			}
			MultimediaParametersDialog{
				id: mediaMenu
				Layout.fillHeight: true
				Layout.leftMargin: 10
				Layout.rightMargin: 10
				Layout.minimumHeight: fitHeight
				Layout.minimumWidth: fitWidth
				radius: 8
				flat: true
				showMargins: true
				fixedSize: false
				onExitStatus: visible = false
				visible: false
			}
		}
		// -------------------------------------------------------------------------
		// Action Buttons.
		// -------------------------------------------------------------------------
		RowLayout{
			Layout.fillWidth: true
			Layout.topMargin: 25
			Layout.bottomMargin: 25
			Layout.leftMargin: 25
			Layout.rightMargin: 25
			Item{
				Layout.fillWidth: true
			}
			// Action buttons			
			RowLayout{
				Layout.alignment: Qt.AlignCenter
				spacing: 30
				RowLayout{
					spacing: 10
					ActionSwitch {
						id: micro
						visible: SettingsModel.muteMicrophoneEnabled
						property bool microMuted: false
						isCustom: true
						backgroundRadius: 90
						colorSet: microMuted ? WaitingRoomStyle.buttons.microOff : WaitingRoomStyle.buttons.microOn
						onClicked: microMuted = !microMuted
					}
					ActionSwitch {
						id: speaker
						property bool speakerMuted: false
						isCustom: true
						backgroundRadius: 90
						colorSet: speakerMuted  ? WaitingRoomStyle.buttons.speakerOff : WaitingRoomStyle.buttons.speakerOn
						onClicked: speakerMuted = !speakerMuted
					}
					ActionSwitch {
						id: camera
						property bool cameraEnabled: true
						isCustom: true
						backgroundRadius: 90
						colorSet: cameraEnabled  ? WaitingRoomStyle.buttons.cameraOn : WaitingRoomStyle.buttons.cameraOff
						enabled: modeChoice.selectedMode != 2
						onClicked: cameraEnabled = !cameraEnabled
					}
				}
				RowLayout{
					ActionButton{
						id: modeChoice
						property int selectedMode: 0
						isCustom: true
						backgroundRadius: width/2
						colorSet: selectedMode == 0 ? WaitingRoomStyle.buttons.gridLayout :
															selectedMode == 1 ?  WaitingRoomStyle.buttons.activeSpeakerLayout : WaitingRoomStyle.buttons.audioOnly
						onClicked: selectedMode = (selectedMode + 1) % 3
					}
				}
			}
			Item{
				Layout.fillWidth: true
			}
		}
		RowLayout{
			Layout.alignment: Qt.AlignCenter
			Layout.bottomMargin: 15
			TextButtonA {
				//: 'Cancel' : Cancel button.
				text: qsTr('cancelButton')
				capitalization: Font.AllUppercase
				
				onClicked: {
						mainItem.close()
						mainItem.cancel()
						}
			}
			TextButtonB {
				//: 'Start' : Button label for starting the conference.
				text: qsTr('startButton')
				capitalization: Font.AllUppercase
		
				onClicked: {mainItem.close(); CallsListModel.launchVideoCall(conferenceInfoModel.uri, '', 0,
																			 {	video: modeChoice.selectedMode != 2
																				, camera: camera.cameraEnabled
																				, micro: !micro.microMuted
																				, audio: !speaker.speakerMuted
																				, layout: (modeChoice.selectedMode % 2)}) }
			}
		}
		
	}
	
}
