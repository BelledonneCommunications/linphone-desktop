import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import UtilsCpp 1.0

import App.Styles 1.0


// Temp
import 'Incall.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Rectangle {
	id: conference
	
	property CallModel callModel
	property ConferenceModel conferenceModel: callModel && callModel.getConferenceModel()
	property var _fullscreen: null
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
	ColumnLayout {
		anchors.fill: parent
		spacing: 0
		
		// -------------------------------------------------------------------------
		// Conference info.
		// -------------------------------------------------------------------------
		RowLayout{
			// Aux features
			Layout.topMargin: 10
			Layout.leftMargin: 25
			Layout.rightMargin: 25
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
				Timer{
					id: elapsedTimeRefresher
					running: true
					interval: 1000
					repeat: true
					onTriggered: parent.elaspedTime = ' - ' +Utils.formatElapsedTime(conferenceModel.getElapsedSeconds())
				}
				property string elaspedTime
				horizontalAlignment: Qt.AlignHCenter
				Layout.fillWidth: true
				text: conferenceModel.subject+ elaspedTime
				color: VideoConferenceStyle.title.color
				font.pointSize: VideoConferenceStyle.title.pointSize
			}
			// Mode buttons
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: VideoConferenceStyle.buttons.screenSharing
			}
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: VideoConferenceStyle.buttons.recordOff
			}
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: VideoConferenceStyle.buttons.screenshot
			}
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: VideoConferenceStyle.buttons.fullscreen
			}
			
		}
		
		// -------------------------------------------------------------------------
		// Contacts visual.
		// -------------------------------------------------------------------------
		
		MouseArea{
			id: mainGrid
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.leftMargin: 70
			Layout.rightMargin: 70
			Layout.topMargin: 15
			Layout.bottomMargin: 20
			onClicked: {
				if(!conference.callModel)
					grid.add({color:  '#'+ Math.floor(Math.random()*255).toString(16)
									  +Math.floor(Math.random()*255).toString(16)
									  +Math.floor(Math.random()*255).toString(16)})
			}
			/*
			ParticipantDeviceProxyModel{
				id: participantDevices
				callModel: conference.callModel
			}*/
			Mosaic {
				id: grid
				anchors.fill: parent
				//anchors.centerIn: parent
				//width: parent.width
				//height: parent.height
				squaredDisplay: true
				
				property int radius : 8
				function setTestMode(){
					grid.clear()
					gridModel.model = gridModel.defaultList
					for(var i = 0 ; i < 5 ; ++i)
						grid.add({color:  '#'+ Math.floor(Math.random()*255).toString(16)
										  +Math.floor(Math.random()*255).toString(16)
										  +Math.floor(Math.random()*255).toString(16)})
					console.log("Setting test mode : count=" + gridModel.defaultList.count)
				}
				function setParticipantDevicesMode(){
					console.log("Setting participant mode : count=" + gridModel.participantDevices.count)
					grid.clear()
					gridModel.model = gridModel.participantDevices
				}
				
				delegateModel: DelegateModel{
					id: gridModel
					property ParticipantDeviceProxyModel participantDevices : ParticipantDeviceProxyModel {
						id: participantDevices
						callModel: conference.callModel
						showMe: true
					}
					/*
					property ListModel defaultList : ListModel{}
					Component.onCompleted: {
						if( conference.callModel ){
							grid.clear()
							gridModel.model = participantDevices
						}
					}
					model: defaultList
					*/
					model: participantDevices
					onCountChanged: {console.log("Delegate count = "+count+"/"+participantDevices.count)}
					delegate: Rectangle{
						id: avatarCell
						property ParticipantDeviceModel currentDevice: gridModel.participantDevices.getAt(index)
						onCurrentDeviceChanged: console.log("currentDevice changed: " +currentDevice + (currentDevice?", me:"+currentDevice.isMe:'')+" ["+index+"]")
						color: /*!conference.callModel && gridModel.defaultList.get(index).color ? gridModel.defaultList.get(index).color : */'#AAAAAAAA'
						//color: gridModel.model.get(index) && gridModel.model.get(index).color ? gridModel.model.get(index).color : ''	// modelIndex is a custom index because by Mosaic modelisation, it is not accessible.
						//color:  $modelData.color ? $modelData.color : ''
						radius: grid.radius
						height: grid.cellHeight - 5
						width: grid.cellWidth - 5
						Component.onCompleted: console.log("Completed: ["+index+"] " +(currentDevice?currentDevice.peerAddress+", isMe:"+currentDevice.isMe : '') )
						
						CameraView{
							anchors.fill: parent
							currentDevice: avatarCell.currentDevice
							hideCamera: callModel.pausedByUser
							onCloseRequested: grid.remove( index)
						}
					}
				}
			}
		}
		// -------------------------------------------------------------------------
		// Action Buttons.
		// -------------------------------------------------------------------------
		RowLayout{
			Layout.fillWidth: true
			Layout.bottomMargin: 40
			Layout.leftMargin: 25
			Layout.rightMargin: 25
			// Security
			ActionButton{
				//Layout.preferredHeight: VideoConferenceStyle.buttons.buttonSize
				//Layout.preferredWidth: VideoConferenceStyle.buttons.buttonSize
				height: VideoConferenceStyle.buttons.secure.buttonSize
				width: height
				isCustom: true
				iconIsCustom: false
				backgroundRadius: width/2
				colorSet: VideoConferenceStyle.buttons.secure
				
				icon: 'secure_level_1'
			}
			Item{
				Layout.fillWidth: true
			}
			// Action buttons			
			RowLayout{
				Layout.alignment: Qt.AlignCenter
				spacing: 30
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
						colorSet: callModel && callModel.videoEnabled  ? VideoConferenceStyle.buttons.cameraOn : VideoConferenceStyle.buttons.cameraOff
						updating: callModel.videoEnabled && callModel.updating
						onClicked: if(callModel) callModel.videoEnabled = !callModel.videoEnabled
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
			Item{
				Layout.fillWidth: true
			}
			// Panel buttons			
			RowLayout{
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
				}
				ActionButton {
					id: callQuality
					
					isCustom: true
					backgroundRadius: 4
					colorSet: VideoConferenceStyle.buttons.callQuality
					percentageDisplayed: 0
					
					onClicked: {console.log("opening stats");Logic.openCallStatistics();console.log("Stats should be opened")}
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
					
					CallStatistics {
						id: callStatistics
						
						call: callModel
						width: conference.width
						relativeTo: keypadButton
						relativeY: CallStyle.header.stats.relativeY
						onClosed: Logic.handleCallStatisticsClosed()
						onOpened: console.log("Stats Opened: " +call+", " +width +", "+relativeY)
					}
				}
				ActionButton{
					isCustom: true
					backgroundRadius: width/2
					colorSet: VideoConferenceStyle.buttons.options
				}
			}
		}
	}
	// ---------------------------------------------------------------------------
	// TelKeypad.
	// ---------------------------------------------------------------------------
	
	TelKeypad {
		id: telKeypad
		
		call: callModel
		visible: SettingsModel.showTelKeypadAutomatically
	}
}
