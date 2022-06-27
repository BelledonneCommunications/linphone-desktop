import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0

import DesktopTools 1.0
import LinphoneEnums 1.0
import UtilsCpp 1.0


import App.Styles 1.0


// Temp
import 'Incall.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

Window {
	id: window

	// ---------------------------------------------------------------------------

	property alias callModel: conference.callModel
	property var caller
	property bool hideButtons: !hideButtonsTimer.realRunning
	property bool cameraIsReady : false
	property bool previewIsReady : false

	// ---------------------------------------------------------------------------

	function exit (cb) {
		DesktopTools.screenSaverStatus = true
		// `exit` is called by `Incall.qml`.
		// The `window` id can be null if the window was closed in this view.
		if (!window) {
			return
		}
		if(!window.close() && parent)
			parent.close()
		if (cb) {
			cb()
		}
	}

	// ---------------------------------------------------------------------------
	onCallModelChanged: if(!callModel) window.exit()
	Component.onCompleted: {
		window.callModel = caller.callModel
	}
	// ---------------------------------------------------------------------------

	Shortcut {
		sequence: StandardKey.Close
		onActivated: window.exit()
	}

	// ---------------------------------------------------------------------------
	// =============================================================================

	Rectangle {
		id: conference

		property CallModel callModel
		property ConferenceModel conferenceModel: callModel && callModel.conferenceModel
		property var _fullscreen: null
		property bool listCallsOpened: false

		signal openListCallsRequest()
		// ---------------------------------------------------------------------------
		anchors.fill: parent
		focus: true

		Keys.onEscapePressed: window.exit()
		color: VideoConferenceStyle.backgroundColor

		Connections {
			target: callModel

			onCameraFirstFrameReceived: Logic.handleCameraFirstFrameReceived(width, height)
			onStatusChanged: Logic.handleStatusChanged (status, conference._fullscreen)
			onVideoRequested: Logic.handleVideoRequested(callModel)
		}

		// ---------------------------------------------------------------------------
		Rectangle{
			anchors.fill: parent
			visible: callModel && callModel.pausedByUser
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
					onClicked: if(callModel) callModel.pausedByUser = !callModel.pausedByUser
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

			visible: !window.hideButtons
			height: visible? undefined : 0
			
			ActionButton{
				id: keypadButton
				isCustom: true
				backgroundRadius: width/2
				colorSet: VideoConferenceStyle.buttons.dialpad
				onClicked: telKeypad.visible = !telKeypad.visible
			}
			// Title
			Text{
				Timer{
					id: elapsedTimeRefresher
					running: true
					interval: 1000
					repeat: true
					onTriggered: if(conference.conferenceModel) parent.elaspedTime = ' - ' +Utils.formatElapsedTime(conference.conferenceModel.getElapsedSeconds())
				}
				property string elaspedTime
				horizontalAlignment: Qt.AlignHCenter
				Layout.fillWidth: true
				text: conference.conferenceModel ? conference.conferenceModel.subject+ elaspedTime : ''
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
				onCallModelChanged: if(callModel) callModel.stopRecording()
				visible: SettingsModel.callRecorderEnabled && callModel
				toggled: callModel && callModel.recording

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
				visible: conference.callModel && conference.callModel.snapshotEnabled
				onClicked: conference.callModel && conference.callModel.takeSnapshot()
				//: 'Take Snapshot' : Tooltip for takking snapshot.
				tooltipText: qsTr('videoConferenceSnapshotTooltip')
			}
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: VideoConferenceStyle.buttons.stopFullscreen
				onClicked: window.exit()
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

			anchors.topMargin: window.hideButtons ? 0 : 15
			anchors.bottomMargin: window.hideButtons ? 0 : 20
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
					Layout.leftMargin: window.hideButtons ? 15 : 70
					Layout.rightMargin: rightMenu.visible ? 15 : 70
					callModel: conference.callModel
					onWidthChanged: console.log("Width: "+width)
				}
			}
			Component{
				id: activeSpeakerComponent
				VideoConferenceActiveSpeaker{
					id: activeSpeaker
					callModel: conference.callModel
					isRightReducedLayout: rightMenu.visible
					isLeftReducedLayout: conference.listCallsOpened
				}
			}
			RowLayout{
				anchors.fill: parent
				Loader{
					id: conferenceLayout
					Layout.fillHeight: true
					Layout.fillWidth: true
					sourceComponent: conference.callModel ? (conference.callModel.conferenceVideoLayout == LinphoneEnums.ConferenceLayoutGrid || !conference.callModel.videoEnabled? gridComponent : activeSpeakerComponent) : null
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
			anchors.bottomMargin: visible ? 30 : 0
			height:  visible ? 60 : 0
			spacing: 30
			z: 2
			visible: !window.hideButtons
			RowLayout{
				spacing: 10
				Row {
					spacing: 2
					visible: SettingsModel.muteMicrophoneEnabled
					property bool microMuted: callModel && callModel.microMuted

					VuMeter {
						enabled: !parent.microMuted
						Timer {
							interval: 50
							repeat: true
							running: parent.enabled

							onTriggered: if(callModel) parent.value = callModel.microVu
						}
					}
					ActionSwitch {
						id: micro
						isCustom: true
						backgroundRadius: 90
						colorSet: parent.microMuted ? VideoConferenceStyle.buttons.microOff : VideoConferenceStyle.buttons.microOn
						onClicked: if(callModel) callModel.microMuted = !parent.microMuted
					}
				}
				Row {
					spacing: 2
					property bool speakerMuted: callModel && callModel.speakerMuted
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
						onClicked: if(callModel) callModel.speakerMuted = !parent.speakerMuted
					}
				}
				ActionSwitch {
					id: camera
					isCustom: true
					backgroundRadius: 90
					colorSet: callModel && callModel.cameraEnabled  ? VideoConferenceStyle.buttons.cameraOn : VideoConferenceStyle.buttons.cameraOff
					updating: callModel && callModel.videoEnabled && callModel.updating
					enabled: callModel && callModel.videoEnabled
					onClicked: if(callModel) callModel.cameraEnabled = !callModel.cameraEnabled
				}
			}
			RowLayout{
				spacing: 10
				ActionButton{
					isCustom: true
					backgroundRadius: width/2
					visible: SettingsModel.callPauseEnabled
					updating: callModel && callModel.updating
					colorSet: callModel && callModel.pausedByUser ? VideoConferenceStyle.buttons.play : VideoConferenceStyle.buttons.pause
					onClicked: if(callModel) callModel.pausedByUser = !callModel.pausedByUser
				}
				ActionButton{
					isCustom: true
					backgroundRadius: width/2
					colorSet: VideoConferenceStyle.buttons.hangup

					onClicked: if(callModel) callModel.terminate()
				}
			}
		}

		// Panel buttons
		RowLayout{
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			anchors.bottomMargin: visible ? 30 : 0
			anchors.rightMargin: 25
			height: visible ? 60 : 0
			visible: !window.hideButtons
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
				visible: false	// TODO
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
						if(callModel) {
							// Note: `quality` is in the [0, 5] interval and -1.
							var quality = callModel.quality
							if(quality >= 0)
								callQuality.percentageDisplayed = quality * 100 / 5
							else
								callQuality.percentageDisplayed = 0
						}
					}
				}
			}
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: VideoConferenceStyle.buttons.options
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
	}
	TelKeypad {
		id: telKeypad
		
		call: callModel
		visible: SettingsModel.showTelKeypadAutomatically
		y: 50
	}
	MouseArea{
		Timer {
			id: hideButtonsTimer
			property bool realRunning : true

			interval: 5000
			running: true
			triggeredOnStart: true
			onTriggered: {if(realRunning != running) realRunning = running}
			function startTimer(){
				restart();
			}
			function stopTimer(){
				stop();
				realRunning = false;
			}
		}

		anchors.fill: parent
		acceptedButtons: Qt.NoButton
		propagateComposedEvents: true
		cursorShape: Qt.ArrowCursor

		onEntered: hideButtonsTimer.startTimer()
		onExited: hideButtonsTimer.stopTimer()

		onPositionChanged: {
			hideButtonsTimer.startTimer()
		}
	}
}
