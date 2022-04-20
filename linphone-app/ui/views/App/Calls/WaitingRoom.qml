import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import Common 1.0
import Linphone 1.0

import Common.Styles 1.0
import App.Styles 1.0

// =============================================================================

Rectangle {
	color: WaitingRoomStyle.backgroundColor
	property ConferenceInfoModel conferenceInfoModel
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
		Item{
			Layout.fillWidth: true
			Layout.fillHeight: true
			CameraView{
				id: previewLoader
				showCloseButton: false
				anchors.centerIn: parent
				height: parent.height
				width : height
			}
		}
		/*
		Loader{
			id: previewLoader
			Layout.fillWidth: true
			Layout.fillHeight: true
			sourceComponent: Item{
				anchors.top:parent.top
				anchors.bottom: parent.bottom
				width : height
			
				Rectangle{
					id: showArea
					anchors.fill: parent
					radius: 10
					visible:false
					color: 'red'
				}
				CameraPreview {
					id: preview
					anchors.fill: parent
					onRequestNewRenderer: {previewLoader.active = false; previewLoader.active = true}
					visible: false
				}
				
				OpacityMask{
					anchors.fill: preview
					source: preview
					maskSource: showArea
		
					visible: true
					rotation: 180
					
				}
			}
			active: true
		}*/
		// -------------------------------------------------------------------------
		// Action Buttons.
		// -------------------------------------------------------------------------
		RowLayout{
			Layout.fillWidth: true
			Layout.bottomMargin: 40
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
						//updating: cameraEnabled && callModel.updating
						onClicked: cameraEnabled = !cameraEnabled
					}
				}
				RowLayout{
					ActionButton{
						isCustom: true
						backgroundRadius: width/2
						colorSet: WaitingRoomStyle.buttons.gridLayout
						/*
						colorSet: callModel.pausedByUser ? WaitingRoomStyle.buttons.play : WaitingRoomStyle.buttons.pause
						onClicked: callModel.pausedByUser = !callModel.pausedByUser
						*/
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
				text: 'CANCEL'
				
				onClicked: console.log('cancel')
			}
			TextButtonB {
				text: 'DEMARRER'
		
				onClicked: CallsListModel.launchVideoCall(conferenceInfoModel.uri, '', 0, {video: camera.cameraEnabled, micro:!micro.microMuted, audio:!speaker.speakerMuted})
			}
		}
		
		/*
		GridLayout {
			columns: parent.width < CallStyle.actionArea.lowWidth && call.videoEnabled ? 1 : 2
			rowSpacing: ActionBarStyle.spacing
			
			anchors {
				left: parent.left
				leftMargin: CallStyle.actionArea.leftButtonsGroupMargin
				verticalCenter: parent.verticalCenter
			}
			
			ActionSwitch {
				isCustom: true
				backgroundRadius: 90
				colorSet: enabled ? CallStyle.buttons.microOn : CallStyle.buttons.microOff
				enabled: !call.microMuted
				
				onClicked: call.microMuted = enabled
			}
		}
		
		Item {
			anchors.centerIn: parent
			height: CallStyle.actionArea.userVideo.height
			width: CallStyle.actionArea.userVideo.width
			
			visible: call.videoEnabled
		}
		
		ActionBar {
			anchors {
				right: parent.right
				rightMargin: CallStyle.actionArea.rightButtonsGroupMargin
				verticalCenter: parent.verticalCenter
			}
			iconSize: CallStyle.actionArea.iconSize
			
			ActionButton {
				isCustom: true
				backgroundRadius: 90
				colorSet: CallStyle.buttons.hangup
				
				onClicked: call.terminate()
			}
		}
		*/
	}
}
