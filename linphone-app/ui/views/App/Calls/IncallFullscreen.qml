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
		color: hideButtons ? IncallStyle.fullBackgroundColor : IncallStyle.backgroundColor

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
			color: IncallStyle.pauseArea.backgroundColor
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
					colorSet: IncallStyle.pauseArea.play
					backgroundRadius: width/2
					onClicked: if(callModel) callModel.pausedByUser = !callModel.pausedByUser
				}
				Text{
					Layout.alignment: Qt.AlignCenter
					
					//: 'You are currently out of the conference.' : Pause message in video conference.
					text: qsTr('incallPauseWarning')
					font.pointSize: IncallStyle.pauseArea.title.pointSize
					font.weight: IncallStyle.pauseArea.title.weight
					color: IncallStyle.pauseArea.title.color
				}
				Text{
					Layout.topMargin: 10
					Layout.alignment: Qt.AlignCenter
					//: 'Click on play button to join it back.' : Explain what to do when being in pause in conference.
					text: qsTr('incallPauseHint')
					font.pointSize: IncallStyle.pauseArea.description.pointSize
					font.weight: IncallStyle.pauseArea.description.weight
					color: IncallStyle.pauseArea.description.color
				}
				Item{
					Layout.fillWidth: true
					Layout.fillHeight: true
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

			anchors.topMargin: window.hideButtons ? 0 : 10
			anchors.leftMargin: 25
			anchors.rightMargin: 25
			spacing: 10

			visible: !window.hideButtons
			height: visible? undefined : 0
			
			ActionButton{
				id: keypadButton
				isCustom: true
				backgroundRadius: width/2
				colorSet: IncallStyle.buttons.dialpad
				onClicked: telKeypad.visible = !telKeypad.visible
			}
			ActionButton {
				id: callQuality

				isCustom: true
				backgroundRadius: width/2
				colorSet: IncallStyle.buttons.callQuality
				icon: IncallStyle.buttons.callQuality.icon_0
				toggled: callStatistics.isOpen
			
				onClicked: callStatistics.isOpen ? callStatistics.close() : callStatistics.open()
			
				Timer {
					interval: 500
					repeat: true
					running: true
					triggeredOnStart: true
					onTriggered: {
						if(callModel) {
							// Note: `quality` is in the [0, 5] interval and -1.
							var quality = callModel.quality
							if(quality > 4)
								callQuality.icon = IncallStyle.buttons.callQuality.icon_4
							else if(quality > 3)
								callQuality.icon = IncallStyle.buttons.callQuality.icon_3
							else if(quality > 2)
								callQuality.icon = IncallStyle.buttons.callQuality.icon_2
							else if(quality > 1)
								callQuality.icon = IncallStyle.buttons.callQuality.icon_1
							else
								callQuality.icon = IncallStyle.buttons.callQuality.icon_0
						}
					}
				}
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
				color: IncallStyle.title.color
				font.pointSize: IncallStyle.title.pointSize
			}
			// Mode buttons
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: IncallStyle.buttons.screenSharing
				visible: false	//TODO
			}
			ActionButton {
				id: recordingSwitch
				isCustom: true
				backgroundRadius: width/2
				colorSet: IncallStyle.buttons.record
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
				tooltipText: !toggled ? qsTr('incallStartRecordTooltip')
				//: 'Stop Recording' : Tooltip when stopping record.
					: qsTr('incallStopRecordTooltip')
			}
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: IncallStyle.buttons.screenshot
				visible: conference.callModel && conference.callModel.snapshotEnabled
				onClicked: conference.callModel && conference.callModel.takeSnapshot()
				//: 'Take Snapshot' : Tooltip for takking snapshot.
				tooltipText: qsTr('incallSnapshotTooltip')
			}
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: IncallStyle.buttons.stopFullscreen
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
			anchors.bottom: zrtp.top

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
				IncallGrid{
					id: grid
					Layout.leftMargin: window.hideButtons ? 15 : 70
					Layout.rightMargin: rightMenu.visible ? 15 : 70
					callModel: conference.callModel
					onWidthChanged: console.log("Width: "+width)
				}
			}
			Component{
				id: activeSpeakerComponent
				IncallActiveSpeaker{
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
					
					sourceComponent: conference.callModel
										? conference.conferenceModel
											? conference.callModel.conferenceVideoLayout == LinphoneEnums.ConferenceLayoutActiveSpeaker
												? activeSpeakerComponent
												: gridComponent
											: activeSpeakerComponent
										: null
					active: conference.callModel
					ColumnLayout {
						anchors.fill: parent
						visible: !conference.callModel || !conferenceLayout.item || conferenceLayout.item.participantCount == 0
						BusyIndicator{
							Layout.preferredHeight: 50
							Layout.preferredWidth: 50
							Layout.alignment: Qt.AlignCenter
							running: parent.visible
							color: IncallStyle.buzyColor
						}
						Text{
							Layout.alignment: Qt.AlignCenter
							//: 'The meeting is not ready. Please Wait...' :  Waiting message for starting a meeting.
							text: qsTr('incallWaitMessage')
							color: IncallStyle.buzyColor
						}
					}
				}
				IncallMenu{
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
		ZrtpTokenAuthentication {
			id: zrtp
			
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.margins: CallStyle.container.margins
			anchors.bottom: actionsButtons.top
			height: visible ? implicitHeight : 0
			
			call: callModel
			visible: !call.isSecured && call.encryption !== CallModel.CallEncryptionNone
			z: Constants.zPopup
		}
	// Security
		ActionButton{
			id: securityButton
			visible: !window.hideButtons && callModel && !callModel.isConference
			anchors.left: parent.left
			anchors.verticalCenter: actionsButtons.verticalCenter
			anchors.leftMargin: 25
			height: IncallStyle.buttons.secure.buttonSize
			width: height
			isCustom: true
			backgroundRadius: width/2
			
			colorSet: callModel.isSecured ? IncallStyle.buttons.secure : IncallStyle.buttons.unsecure
						
			onClicked: zrtp.visible = (callModel.encryption === CallModel.CallEncryptionZrtp)
						
			tooltipText: Logic.makeReadableSecuredString(callModel.securedString)
		}
		RowLayout{
			visible: callModel && callModel.remoteRecording
			
			anchors.verticalCenter: !window.hideButtons ? actionsButtons.verticalCenter : undefined
			anchors.bottom: window.hideButtons ? parent.bottom : undefined
			anchors.bottomMargin: window.hideButtons ? 20 : 0
			anchors.left: securityButton.right
			anchors.leftMargin: 20
			anchors.right: actionsButtons.left
			anchors.rightMargin: 10
			
			Icon{
				icon: IncallStyle.recordWarning.icon
				iconSize: IncallStyle.recordWarning.iconSize
				overwriteColor: IncallStyle.recordWarning.iconColor
			}
			Text{
				Layout.fillWidth: true
				//: 'This call is being recorded.' : Warn the user that the remote is currently recording the call.
				text: qsTr('callWarningRecord')
				color: IncallStyle.recordWarning.color
				font.italic: true
				font.pointSize: IncallStyle.recordWarning.pointSize
				wrapMode: Text.WordWrap
			}
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
						colorSet: parent.microMuted ? IncallStyle.buttons.microOff : IncallStyle.buttons.microOn
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
						colorSet: parent.speakerMuted  ? IncallStyle.buttons.speakerOff : IncallStyle.buttons.speakerOn
						onClicked: if(callModel) callModel.speakerMuted = !parent.speakerMuted
					}
				}
				ActionSwitch {
					id: camera
					isCustom: true
					backgroundRadius: 90
					colorSet: callModel && callModel.cameraEnabled  ? IncallStyle.buttons.cameraOn : IncallStyle.buttons.cameraOff
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
					colorSet: callModel && callModel.pausedByUser ? IncallStyle.buttons.play : IncallStyle.buttons.pause
					onClicked: if(callModel) callModel.pausedByUser = !callModel.pausedByUser
				}
				ActionButton{
					isCustom: true
					backgroundRadius: width/2
					colorSet: IncallStyle.buttons.hangup

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
			/* Not available in fullscreen yet.
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: IncallStyle.buttons.chat
				visible: false && (SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled) && callModel && !callModel.isConference
				toggled: window.chatIsOpened
				onClicked: {
							if (window.chatIsOpened) {
								window.closeChat()
							} else {
								window.openChat()
							}
						}
			}*/
			ActionButton{
				visible: callModel && callModel.isConference
				isCustom: true
				backgroundRadius: width/2
				colorSet: IncallStyle.buttons.participants
				toggled: rightMenu.visible && rightMenu.isParticipantsMenu
				onClicked: {
						if(toggled)
							rightMenu.visible = false
						else
							rightMenu.showParticipantsMenu()
					}
			}
			
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: IncallStyle.buttons.options
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
		}
	}
	TelKeypad {
		id: telKeypad
		showHistory:true
		call: callModel
		visible: SettingsModel.showTelKeypadAutomatically
		y: 50
	}
	MouseArea{
		Timer {
			id: hideButtonsTimer
			property bool realRunning : false
			property bool firstUse: true

			interval: firstUse ? 500 : 4000
			running: false
			triggeredOnStart: !firstUse
			onTriggered: {if(!firstUse && realRunning != running) realRunning = running
							firstUse = false}
			function startTimer(){
				if(!firstUse || !running)
					restart();
			}
			function stopTimer(){
				stop()
				realRunning = false
				hideButtonsTimer.firstUse = false
			}
		}

		anchors.fill: parent
		acceptedButtons: Qt.NoButton
		propagateComposedEvents: true
		cursorShape: undefined
		//cursorShape: Qt.ArrowCursor
		onEntered: hideButtonsTimer.startTimer()
		onExited: {
			var cursorPosition = UtilsCpp.getCursorPosition()
			mapToItem(window.contentItem, cursorPosition.x, cursorPosition.y)
			if (cursorPosition.x <= 0 || cursorPosition.y <= 0
					|| cursorPosition.x >= width || cursorPosition.y >= height)
				hideButtonsTimer.stopTimer()
		}
		onPositionChanged: hideButtonsTimer.startTimer()
	}
}
