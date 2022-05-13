import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0

import LinphoneEnums 1.0
import UtilsCpp 1.0

import App.Styles 1.0


// Temp
import 'Incall.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Rectangle {
	id: conference
	
	property CallModel callModel
	property ConferenceModel conferenceModel: callModel && callModel.conferenceModel
	property bool cameraIsReady : false
	property bool previewIsReady : false
	property bool isFullScreen: false	// Use this variable to test if we are in fullscreen. Do not test _fullscreen : we need to clean memory before having the window (see .js file)
	property var _fullscreen: null
	on_FullscreenChanged: if( !_fullscreen) isFullScreen = false

	property bool listCallsOpened: true
	
	signal openListCallsRequest()
	// ---------------------------------------------------------------------------
	
	color: VideoConferenceStyle.backgroundColor
	
	Connections {
		target: callModel
		
		onCameraFirstFrameReceived: Logic.handleCameraFirstFrameReceived(width, height)
		onStatusChanged: Logic.handleStatusChanged (status)
		onVideoRequested: Logic.handleVideoRequested(callModel)
	}
	
	// ---------------------------------------------------------------------------
	Rectangle{
		MouseArea{
			anchors.fill: parent
		}
		anchors.fill: parent
		visible: callModel.pausedByUser
		color: VideoConferenceStyle.pauseArea.backgroundColor
		z: 1
		ColumnLayout{
			anchors.fill: parent
			spacing: 10
			Item{
				Layout.fillWidth: true
				Layout.fillHeight: true
			}
			ActionButton{
				Layout.alignment: Qt.AlignCenter
				isCustom: true
				colorSet: VideoConferenceStyle.pauseArea.play
				backgroundRadius: width/2
				onClicked: callModel.pausedByUser = !callModel.pausedByUser
			}
			Text{
				Layout.alignment: Qt.AlignCenter
				//: 'You are currently out of the conference.' : Pause message in video conference.
				text: qsTr('videoConferencePauseWarning')
				font.pointSize: VideoConferenceStyle.pauseArea.title.pointSize
				font.weight: VideoConferenceStyle.pauseArea.title.weight
				color: VideoConferenceStyle.pauseArea.title.color
			}
			Text{
				Layout.alignment: Qt.AlignCenter
				//: 'Click on play button to join it back.' : Explain what to do when being in pause in conference.
				text: qsTr('videoConferencePauseHint')
				font.pointSize: VideoConferenceStyle.pauseArea.description.pointSize
				font.weight: VideoConferenceStyle.pauseArea.description.weight
				color: VideoConferenceStyle.pauseArea.description.color
			}
			Item{
				Layout.fillWidth: true
				Layout.preferredHeight: 140
			}
		}
	}
	
	// -------------------------------------------------------------------------
	// Conference info.
	// -------------------------------------------------------------------------
	RowLayout{
		id: featuresRow
		// Aux features
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		
		anchors.topMargin: 10
		anchors.leftMargin: 25
		anchors.rightMargin: 25
		spacing: 10
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.callsList
			visible: !listCallsOpened
			onClicked: openListCallsRequest()
		}
		ActionButton{
			id: keypadButton
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.dialpad
			onClicked: telKeypad.visible = !telKeypad.visible
		}
		// Title
		Text{
			id: title
			Timer{
				id: elapsedTimeRefresher
				running: true
				interval: 1000
				repeat: true
				onTriggered: if(conferenceModel) parent.elaspedTime = ' - ' +Utils.formatElapsedTime(conferenceModel.getElapsedSeconds())
			}
			property string elaspedTime
			horizontalAlignment: Qt.AlignHCenter
			Layout.fillWidth: true
			text: conferenceModel ? conferenceModel.subject+ elaspedTime : ''
			color: VideoConferenceStyle.title.color
			font.pointSize: VideoConferenceStyle.title.pointSize
		}
		// Mode buttons
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.screenSharing
			visible: false	//TODO
		}
		ActionButton {
			id: recordingSwitch
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.record
			property CallModel callModel: conference.callModel
			onCallModelChanged: if(!callModel) callModel.stopRecording()
			visible: SettingsModel.callRecorderEnabled && callModel
			toggled: callModel.recording

			onClicked: {
				return !toggled
						? callModel.startRecording()
						: callModel.stopRecording()
			}
			//: 'Start recording' : Tootltip when straing record.
			tooltipText: !toggled ? qsTr('videoConferenceStartRecordTooltip')
			//: 'Stop Recording' : Tooltip when stopping record.
			: qsTr('videoConferenceStopRecordTooltip')
		}
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.screenshot
			visible: conference.callModel.snapshotEnabled
			onClicked: conference.callModel.takeSnapshot()
			//: 'take Snapshot' : Tooltip for takking snapshot.
			tooltipText: qsTr('videoConferenceSnapshotTooltip')
		}
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.fullscreen
			visible: conference.callModel.videoEnabled
			onClicked: Logic.showFullscreen(window, conference, 'VideoConferenceFullscreen.qml', title.mapToGlobal(0,0))
		}
		
	}
	
	// -------------------------------------------------------------------------
	// Contacts visual.
	// -------------------------------------------------------------------------
	
	MouseArea{
		id: mainGrid
		anchors.top: featuresRow.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: actionsButtons.top
		
		anchors.topMargin: 15
		anchors.bottomMargin: 20
		onClicked: {
			if(!conference.callModel)
				grid.add({color:  '#'+ Math.floor(Math.random()*255).toString(16)
								  +Math.floor(Math.random()*255).toString(16)
								  +Math.floor(Math.random()*255).toString(16)})
		}
		
		Component{
			id: gridComponent
			VideoConferenceGrid{
				id: grid
				Layout.leftMargin: 70
				Layout.rightMargin: rightMenu.visible ? 15 : 70
				callModel: conference.callModel
				cameraEnabled: !conference.isFullScreen
			}
		}
		Component{
			id: activeSpeakerComponent
			VideoConferenceActiveSpeaker{
				id: activeSpeaker
				callModel: conference.callModel
				isRightReducedLayout: rightMenu.visible
				isLeftReducedLayout: conference.listCallsOpened
				cameraEnabled: !conference.isFullScreen
			}
		}
		RowLayout{
			anchors.fill: parent
			Loader{
				id: conferenceLayout
				Layout.fillHeight: true
				Layout.fillWidth: true
				sourceComponent: conference.callModel.conferenceVideoLayout == LinphoneEnums.ConferenceLayoutGrid || !conference.callModel.videoEnabled? gridComponent : activeSpeakerComponent
				onSourceComponentChanged: console.log(conference.callModel.conferenceVideoLayout)
				active: conference.callModel
				ColumnLayout {
					anchors.fill: parent
					visible: !conference.callModel || !conferenceLayout.item || conferenceLayout.item.participantCount == 0
					BusyIndicator{
						Layout.preferredHeight: 50
						Layout.preferredWidth: 50
						Layout.alignment: Qt.AlignCenter
						running: parent.visible
						color: VideoConferenceStyle.buzyColor
					}
					Text{
						Layout.alignment: Qt.AlignCenter
						//: 'Video conference is not ready. Please Wait...' :  Waiting message for starting conference.
						text: qsTr('videoConferenceWaitMessage')
						color: VideoConferenceStyle.buzyColor
					}
				}
			}
			VideoConferenceMenu{
				id: rightMenu
				Layout.fillHeight: true
				Layout.preferredWidth: 400
				Layout.rightMargin: 30
				callModel: conference.callModel
				conferenceModel: conference.conferenceModel
				visible: false
				onClose: rightMenu.visible = !rightMenu.visible
			}
		}
	}
	// -------------------------------------------------------------------------
	// Action Buttons.
	// -------------------------------------------------------------------------
	
	// Security
	ActionButton{
		visible: false	// TODO
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 30
		anchors.leftMargin: 25
		height: VideoConferenceStyle.buttons.secure.buttonSize
		width: height
		isCustom: true
		iconIsCustom: false
		backgroundRadius: width/2
		colorSet: VideoConferenceStyle.buttons.secure
		
		icon: 'secure_level_1'
	}
	// Action buttons			
	RowLayout{
		id: actionsButtons
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 30
		height: 60
		spacing: 30
		z: 2
		RowLayout{
			spacing: 10
			Row {
				spacing: 2
				visible: SettingsModel.muteMicrophoneEnabled
				property bool microMuted: callModel.microMuted
				
				VuMeter {
					enabled: !parent.microMuted
					Timer {
						interval: 50
						repeat: true
						running: parent.enabled
						
						onTriggered: parent.value = callModel.microVu
					}
				}
				ActionSwitch {
					id: micro
					isCustom: true
					backgroundRadius: 90
					colorSet: parent.microMuted ? VideoConferenceStyle.buttons.microOff : VideoConferenceStyle.buttons.microOn
					onClicked: callModel.microMuted = !parent.microMuted
				}
			}
			Row {
				spacing: 2
				property bool speakerMuted: callModel.speakerMuted
				VuMeter {
					enabled: !parent.speakerMuted
					Timer {
						interval: 50
						repeat: true
						running: parent.enabled
						onTriggered: parent.value = callModel.speakerVu
					}
				}
				ActionSwitch {
					id: speaker
					isCustom: true
					backgroundRadius: 90
					colorSet: parent.speakerMuted  ? VideoConferenceStyle.buttons.speakerOff : VideoConferenceStyle.buttons.speakerOn
					onClicked: callModel.speakerMuted = !parent.speakerMuted
				}
			}
			ActionSwitch {
				id: camera
				isCustom: true
				backgroundRadius: 90
				colorSet: callModel && callModel.cameraEnabled  ? VideoConferenceStyle.buttons.cameraOn : VideoConferenceStyle.buttons.cameraOff
				updating: callModel.videoEnabled && callModel.updating
				enabled: callModel.videoEnabled
				onClicked: if(callModel) callModel.cameraEnabled = !callModel.cameraEnabled
			}
		}
		RowLayout{
			spacing: 10
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				visible: SettingsModel.callPauseEnabled
				updating: callModel.updating
				colorSet: callModel.pausedByUser ? VideoConferenceStyle.buttons.play : VideoConferenceStyle.buttons.pause
				onClicked: callModel.pausedByUser = !callModel.pausedByUser
			}
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: VideoConferenceStyle.buttons.hangup
				
				onClicked: callModel.terminate()
			}
		}
	}
	
	// Panel buttons			
	RowLayout{
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 30
		anchors.rightMargin: 25
		height: 60
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.chat
			visible: false	// TODO for next version
		}
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.participants
			toggled: rightMenu.visible && rightMenu.isParticipantsMenu
			onClicked: {
					if(toggled)
						rightMenu.visible = false
					else
						rightMenu.showParticipantsMenu()
				}
		}
		ActionButton {
			id: callQuality
			
			isCustom: true
			backgroundRadius: 4
			colorSet: VideoConferenceStyle.buttons.callQuality
			percentageDisplayed: 0
			
			onClicked: {Logic.openCallStatistics();}
			Timer {
				interval: 500
				repeat: true
				running: true
				triggeredOnStart: true
				onTriggered: {
					// Note: `quality` is in the [0, 5] interval and -1.
					var quality = callModel.quality
					if(quality >= 0)
						callQuality.percentageDisplayed = quality * 100 / 5
					else
						callQuality.percentageDisplayed = 0
				}						
			}
		}
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.options
			toggled: rightMenu.visible
			onClicked: rightMenu.visible = !rightMenu.visible
		}
	}
	
	// ---------------------------------------------------------------------------
	// TelKeypad.
	// ---------------------------------------------------------------------------
	CallStatistics {
		id: callStatistics
		
		call: conference.callModel
		width: conference.width - 20
		height: conference.height * 2/3
		relativeTo: conference
		relativeY: CallStyle.header.stats.relativeY
		relativeX: 10
		onClosed: Logic.handleCallStatisticsClosed()
	}
	TelKeypad {
		id: telKeypad
		
		call: callModel
		visible: SettingsModel.showTelKeypadAutomatically
	}
}
