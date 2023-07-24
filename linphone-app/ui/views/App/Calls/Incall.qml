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
	id: mainItem
	
	property CallModel callModel
	property ConferenceModel conferenceModel: callModel && callModel.conferenceModel
	property bool cameraIsReady : false
	property bool previewIsReady : false
	property bool isFullScreen: false	// Use this variable to test if we are in fullscreen. Do not test _fullscreen : we need to clean memory before having the window (see .js file)
	property bool layoutChanging: false
	
	property var _fullscreen: null
	on_FullscreenChanged: if( !_fullscreen) isFullScreen = false

	property bool listCallsOpened: true
	
	signal openListCallsRequest()
	
	property int participantCount: mainItem.conferenceModel
									? mainItem.conferenceModel.participantDeviceCount
									: conferenceLayout.item ? conferenceLayout.item.participantCount : 2
	
// States
	property bool isAudioOnly:  callModel && callModel.conferenceVideoLayout == LinphoneEnums.ConferenceLayoutAudioOnly
	property bool isReady : mainItem.callModel && mainItem.callModel.status != CallModel.CallStatusIdle
								&& (!mainItem.callModel.isConference 
																|| (mainItem.conferenceModel && mainItem.conferenceModel.isReady)
														)
								&& conferenceLayout.item && conferenceLayout.status == Loader.Ready
	function updateMessageBanner(){
		//: ''You are alone in this conference' : Text in message banner when the user is the only participant.
		if( conferenceModel && isReady && participantCount <= 1) messageBanner.noticeBannerText = qsTr('aloneInConference')
	}
	Timer{
		id: delayMessageBanner
		interval: 100
		onTriggered: updateMessageBanner()
	}
	onParticipantCountChanged: Qt.callLater(function (){delayMessageBanner.restart()})
	onIsReadyChanged: Qt.callLater(function (){delayMessageBanner.restart()})
	
	// ---------------------------------------------------------------------------
	
	color: IncallStyle.backgroundColor.color
	
	Connections {
		target: callModel
		
		onCameraFirstFrameReceived: Logic.handleCameraFirstFrameReceived(width, height)
		onStatusChanged: {Logic.handleStatusChanged (status, mainItem._fullscreen)
			delayMessageBanner.restart()
		}
		onVideoRequested: Logic.handleVideoRequested(callModel)
		onEncryptionChanged: if(!callModel.isSecured && callModel.encryption === CallModel.CallEncryptionZrtp){
							window.attachVirtualWindow(Utils.buildLinphoneDialogUri('ZrtpTokenAuthenticationDialog'), {call:callModel})
						}
	}
	// ---------------------------------------------------------------------------
	Rectangle{
		MouseArea{
			anchors.fill: parent
		}
		anchors.fill: parent
		visible: callModel.pausedByUser || (callModel.isOneToOne && callModel.pausedByRemote)
		color: IncallStyle.pauseArea.backgroundColor.color
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
				colorSet: callModel.pausedByUser ? IncallStyle.pauseArea.play : IncallStyle.pauseArea.pause
				backgroundRadius: width/2
				enabled: callModel.pausedByUser
				onClicked: callModel.pausedByUser = !callModel.pausedByUser
			}
			Text{
				Layout.alignment: Qt.AlignCenter
				text: callModel.pausedByUser
				//: 'You have paused the call.' : Pause message in call.
						? qsTr('incallPauseWarning')
				//: 'Call has been paused by remote.' : Remote pause message in call.
						: qsTr('incallRemotePauseWarning')
				font.pointSize: IncallStyle.pauseArea.title.pointSize
				font.weight: IncallStyle.pauseArea.title.weight
				color: IncallStyle.pauseArea.title.colorModel.color
			}
			Text{
				Layout.topMargin: 10
				Layout.alignment: Qt.AlignCenter
				
				text: callModel.pausedByUser
				//: 'Click on play button to join it back.' : Explain what to do when being in pause in conference.
							? qsTr('incallPauseHint')
							: ''
				font.pointSize: IncallStyle.pauseArea.description.pointSize
				font.weight: IncallStyle.pauseArea.description.weight
				color: IncallStyle.pauseArea.description.colorModel.color
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
		
		anchors.topMargin: 10
		anchors.leftMargin: 25
		anchors.rightMargin: 25
		spacing: 10
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: IncallStyle.buttons.callsList
			visible: !listCallsOpened && mainItem.isReady
			onClicked: openListCallsRequest()
		}
		ActionButton{
			id: keypadButton
			isCustom: true
			backgroundRadius: width/2
			colorSet: IncallStyle.buttons.dialpad
			visible: mainItem.isReady
			toggled: telKeypad.visible
			onClicked: telKeypad.visible = !telKeypad.visible
		}
		ActionButton {
			id: callQuality
			
			isCustom: true
			backgroundRadius: width/2
			colorSet: IncallStyle.buttons.callQuality
			icon: IncallStyle.buttons.callQuality.icon_0
			visible: mainItem.isReady
			toggled: callStatistics.isOpen
			
			onClicked: callStatistics.isOpen ? callStatistics.close() : callStatistics.open()
			Timer {
				interval: 500
				repeat: true
				running: true
				triggeredOnStart: true
				onTriggered: {
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
		
		// Title
		Item{
			Layout.fillWidth: true
			Layout.preferredHeight: title.contentHeight + address.contentHeight
			property int centerOffset: mapFromItem(mainItem, mainItem.width/2,0).x - width/2	// Compute center from mainItem
			ColumnLayout{
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				width: parent.width
				x: parent.centerOffset
				
				Text{
					id: title
					Layout.alignment: Qt.AlignHCenter
					Timer{
						id: elapsedTimeRefresher
						running: true
						interval: 1000
						repeat: true
						onTriggered: if(conferenceModel) parent.elaspedTime = Utils.formatElapsedTime(conferenceModel.getElapsedSeconds())
									else parent.elaspedTime = Utils.formatElapsedTime(mainItem.callModel.duration)
					}
					property string elaspedTime
					horizontalAlignment: Qt.AlignHCenter
					Layout.fillWidth: true
					text: conferenceModel 
							? conferenceModel.subject
								? conferenceModel.subject+ (elaspedTime ? ' - ' +elaspedTime : '')
								: elaspedTime
							: callModel
								? elaspedTime
								: ''
					color: IncallStyle.title.colorModel.color
					font.pointSize: IncallStyle.title.pointSize
				}
				Text{
					id: address
					Layout.fillWidth: true
					horizontalAlignment: Qt.AlignHCenter
					visible: !conferenceModel && callModel && !callModel.isConference && text != title.text
					text: !conferenceModel && callModel
								? UtilsCpp.toDisplayString(SipAddressesModel.cleanSipAddress(callModel.peerAddress), SettingsModel.sipDisplayMode)
								: ''
					color: IncallStyle.title.colorModel.color
					font.pointSize: IncallStyle.title.addressPointSize
				}
				
			}
			MessageBanner{
				id: messageBanner
				
				anchors.fill: parent
				textColor: IncallStyle.header.messageBanner.textColor.color
				color: IncallStyle.header.messageBanner.colorModel.color
				showIcon: false
				pointSize: IncallStyle.header.messageBanner.pointSize
			}
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
			property CallModel callModel: mainItem.callModel
			visible: SettingsModel.callRecorderEnabled && callModel && (callModel.recording || mainItem.isReady) 
							&& !mainItem.conferenceModel // Remove recording for conference (not fully implemented)
			toggled: callModel.recording

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
			visible: SettingsModel.incallScreenshotEnabled && mainItem.isReady && mainItem.callModel && (!mainItem.callModel.isConference || mainItem.callModel.snapshotEnabled)
			onClicked: mainItem.callModel.takeSnapshot()
			//: 'Take Snapshot' : Tooltip for takking snapshot.
			tooltipText: qsTr('incallSnapshotTooltip')
		}
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: IncallStyle.buttons.fullscreen
			visible: mainItem.callModel.videoEnabled
			onClicked: {
				console.info("[QML] User request fullscreen")
				Logic.showFullscreen(window, mainItem, 'IncallFullscreen.qml', title.mapToGlobal(0,0))
			}
		}
		
	}
	
	// -------------------------------------------------------------------------
	// Contacts visual.
	// -------------------------------------------------------------------------
	
	Item{
		id: mainGrid
		anchors.top: featuresRow.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: actionsButtons.top
		
		anchors.topMargin: 15
		anchors.bottomMargin: 20
		
		Component{
			id: gridComponent
			IncallGrid{
				id: grid
				Layout.leftMargin: 70
				Layout.rightMargin: rightMenu.visible ? 15 : 70
				callModel: mainItem.callModel
				cameraEnabled: !mainItem.isFullScreen && !mainItem.layoutChanging
			}
		}
		Component{
			id: activeSpeakerComponent
			IncallActiveSpeaker{
				id: activeSpeaker
				callModel: mainItem.callModel
				isRightReducedLayout: rightMenu.visible
				isLeftReducedLayout: mainItem.listCallsOpened
				cameraEnabled: !mainItem.isFullScreen && !mainItem.layoutChanging
			}
		}
		RowLayout{
			anchors.fill: parent
			Item{
				Layout.fillHeight: true
				Layout.fillWidth: true
				Loader{
					id: conferenceLayout
					anchors.fill: parent
					
					Timer{// Avoid Qt crashes when layout changes while videos are on
						id: layoutDelay
						interval: 100
						property int step : 0
						property var layoutMode
						onTriggered: {
							switch(step){
							case 2 : step = 0; mainItem.layoutChanging = false; break;
							case 1: ++step; conferenceLayout.sourceComponent = conferenceLayout.getLayout(); layoutDelay.restart(); break;
							case 0: if( mainItem.callModel.conferenceVideoLayout != layoutMode)
										mainItem.callModel.conferenceVideoLayout = layoutMode
									else {
										++step;
										layoutDelay.restart()
									}
									break;
							}
						}
						function begin(layoutMode){
							step = 0
							layoutDelay.layoutMode = layoutMode
							mainItem.layoutChanging = true
							layoutDelay.restart()
						}
					}
					function getLayout(){
						return mainItem.conferenceModel
								? mainItem.callModel.conferenceVideoLayout == LinphoneEnums.ConferenceLayoutActiveSpeaker
									? activeSpeakerComponent
									: gridComponent
								: activeSpeakerComponent
					}
						
					Connections{
						target: mainItem.callModel
						
						onConferenceVideoLayoutChanged: {
							layoutDelay.layoutMode = mainItem.callModel.conferenceVideoLayout
							layoutDelay.restart()
						}
					}
					sourceComponent: getLayout()
					active: mainItem.callModel && !mainItem.isFullScreen
				}
				Rectangle{
					anchors.fill: parent
					color: mainItem.color
					visible: !mainItem.isReady
					ColumnLayout {
						anchors.fill: parent
						Loader{
							Layout.preferredHeight: 40
							Layout.preferredWidth: 40
							Layout.alignment: Qt.AlignCenter
							active: parent.visible
							sourceComponent: Component{
								BusyIndicator{
									color: IncallStyle.buzyColor.color
								}
							}
						}
						Text{
							Layout.alignment: Qt.AlignCenter
							
							text: false //mainItem.needMoreParticipants
							//: 'Waiting for another participant...' :  Waiting message for more participant.
									? qsTr('incallWaitParticipantMessage')
									: mainItem.callModel && mainItem.callModel.isConference
							//: 'The meeting is not ready. Please Wait...' :  Waiting message for starting a meeting.
										? qsTr('incallWaitMessage')
										//: 'The call is not ready. Please Wait...' :  Waiting message for starting a call.
										: qsTr('incallWaitConnectedMessage')
							color: IncallStyle.buzyColor.color
						}
					}
				}
			}
			IncallMenu{
				id: rightMenu
				Layout.fillHeight: true
				Layout.preferredWidth: 400
				Layout.rightMargin: 30
				callModel: mainItem.callModel
				conferenceModel: mainItem.conferenceModel
				visible: false
				enabled: !mainItem.layoutChanging
				onClose: rightMenu.visible = !rightMenu.visible
				onLayoutChanging: {
						layoutDelay.begin(layoutMode)
				}
			}
		}
	}
	// -------------------------------------------------------------------------
	// Action Buttons.
	// -------------------------------------------------------------------------
	
	// Security
	ActionButton{
		id: securityButton
		anchors.left: parent.left
		anchors.verticalCenter: actionsButtons.verticalCenter
		anchors.leftMargin: 25
		height: IncallStyle.buttons.secure.buttonSize
		width: height
		isCustom: true
		iconIsCustom: ! (callModel.isSecured && SettingsModel.isPostQuantumAvailable && callModel.encryption === CallModel.CallEncryptionZrtp)
		backgroundRadius: width/2
		
		colorSet: callModel.isSecured
							? SettingsModel.isPostQuantumAvailable && callModel.encryption === CallModel.CallEncryptionZrtp && callModel.isPQZrtp == CallModel.CallPQStateOn
								? IncallStyle.buttons.postQuantumSecure
								: IncallStyle.buttons.secure
							: IncallStyle.buttons.unsecure
					
		onClicked: if(callModel.encryption === CallModel.CallEncryptionZrtp){
			window.attachVirtualWindow(Utils.buildLinphoneDialogUri('ZrtpTokenAuthenticationDialog'), {call:callModel})
		}
					
		tooltipText: Logic.makeReadableSecuredString(callModel.isSecured, callModel.securedString)
	}
	RowLayout{
		visible: callModel.remoteRecording
		
		anchors.verticalCenter: actionsButtons.verticalCenter
		anchors.left: securityButton.right
		anchors.leftMargin: 20
		anchors.right: actionsButtons.left
		anchors.rightMargin: 10
		
		Icon{
			icon: IncallStyle.recordWarning.icon
			iconSize: IncallStyle.recordWarning.iconSize
			overwriteColor: IncallStyle.recordWarning.iconColor.color
		}
		Text{
			Layout.fillWidth: true
			//: 'This call is being recorded.' : Warn the user that the remote is currently recording the call.
			text: qsTr('callWarningRecord')
			color: IncallStyle.recordWarning.colorModel.color
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
		anchors.bottomMargin: 30
		height: 60
		spacing: 30
		z: 2
		RowLayout{
			spacing: 10
			visible: mainItem.isReady
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
					colorSet: parent.microMuted ? IncallStyle.buttons.microOff : IncallStyle.buttons.microOn
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
					colorSet: parent.speakerMuted  ? IncallStyle.buttons.speakerOff : IncallStyle.buttons.speakerOn
					onClicked: callModel.speakerMuted = !parent.speakerMuted
				}
			}
			ActionSwitch {
				id: camera
				isCustom: true
				backgroundRadius: 90
				colorSet: callModel && callModel.cameraEnabled  ? IncallStyle.buttons.cameraOn : IncallStyle.buttons.cameraOff
				updating: callModel.videoEnabled && callModel.updating && !mainItem.layoutChanging
				enabled: callModel && !callModel.pausedByUser
				visible: SettingsModel.videoAvailable
				property bool _activateCamera: false
				onClicked: if(callModel && !mainItem.layoutChanging){
								if( callModel.isConference){// Only deactivate camera in conference.
									if(mainItem.isAudioOnly) {
										var layout = SettingsModel.videoConferenceLayout != LinphoneEnums.ConferenceLayoutAudioOnly ? SettingsModel.videoConferenceLayout : LinphoneEnums.ConferenceLayoutGrid
										layoutDelay.begin(layout)
										camera._activateCamera = true
									}else
										callModel.cameraEnabled = !callModel.cameraEnabled
								}else{// In one-one, we deactivate all videos.
									callModel.videoEnabled = !callModel.videoEnabled
								}
							}
				Connections{// Enable camera only when status is ok
					target: callModel
					onStatusChanged: if( camera._activateCamera && (status == CallModel.CallStatusConnected || status == CallModel.CallStatusIdle)){
						camera._activateCamera = false
						callModel.cameraEnabled = true
					}
				}
			}
			
		}
		RowLayout{
			spacing: 10
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				visible: SettingsModel.callPauseEnabled && mainItem.isReady
				updating: callModel.updating
				colorSet: callModel.pausedByUser ? IncallStyle.buttons.play : IncallStyle.buttons.pause
				onClicked: callModel.pausedByUser = !callModel.pausedByUser
			}
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: IncallStyle.buttons.hangup
				
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
		visible: mainItem.isReady
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: IncallStyle.buttons.chat
			visible: window.haveChat && (SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled) && callModel && !callModel.isConference
			toggled: window.chatIsOpened
			onClicked: {
						if (window.chatIsOpened) {
							window.closeChat()
						} else {
							window.openChat()
						}
					}
		}
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
		
		call: mainItem.callModel
		width: mainItem.width
		height: mainItem.height
	}
	TelKeypad {
		id: telKeypad
		showHistory:true
		call: callModel
		visible: SettingsModel.showTelKeypadAutomatically
		y: 70
	}
}
