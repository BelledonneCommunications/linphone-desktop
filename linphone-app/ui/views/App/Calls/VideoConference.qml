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
				text: 'Vous êtes actuellement en dehors de la conférence.'
				font.pointSize: VideoConferenceStyle.pauseArea.title.pointSize
				font.weight: VideoConferenceStyle.pauseArea.title.weight
				color: VideoConferenceStyle.pauseArea.title.color
			}
			Text{
				Layout.alignment: Qt.AlignCenter
				text: 'Cliquez sur le bouton "play" pour la rejoindre.'
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
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.recordOff
			visible: false	//TODO
		}
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.screenshot
			visible: false	//TODO
		}
		ActionButton{
			isCustom: true
			backgroundRadius: width/2
			colorSet: VideoConferenceStyle.buttons.fullscreen
			visible: false	//TODO
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
		
		anchors.leftMargin: 70
		anchors.rightMargin: 70
		anchors.topMargin: 15
		anchors.bottomMargin: 20
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
			squaredDisplay: true
			
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
				delegate: Item{
					id: avatarCell
					property ParticipantDeviceModel currentDevice: gridModel.participantDevices.getAt(index)
					onCurrentDeviceChanged: {
						console.log("currentDevice changed: " +currentDevice+"/"+cameraView.currentDevice + (currentDevice?", me:"+currentDevice.isMe:'')+" ["+index+"]")
						if(index < 0) cameraView.enabled = false	// this is a delegate destruction. We need to stop camera before Qt change its currentDevice (and then, let CameraView to delete wrong renderer)
						
					}
					//color: 'black' /*!conference.callModel && gridModel.defaultList.get(index).color ? gridModel.defaultList.get(index).color : */
					//color: gridModel.model.get(index) && gridModel.model.get(index).color ? gridModel.model.get(index).color : ''	// modelIndex is a custom index because by Mosaic modelisation, it is not accessible.
					//color:  $modelData.color ? $modelData.color : ''
					height: grid.cellHeight - 10
					width: grid.cellWidth - 10
					Component.onCompleted: {
						console.log("Completed: ["+index+"] " +(currentDevice?currentDevice.peerAddress+", isMe:"+currentDevice.isMe : '') )
					}
					
					CameraView{
						id: cameraView
						enabled: index >=0
						anchors.fill: parent
						currentDevice: avatarCell.currentDevice
						isPaused: callModel.pausedByUser || avatarCell.currentDevice && avatarCell.currentDevice.isPaused //callModel.pausedByUser
						onCloseRequested: grid.remove( index)
						color: 'black'
					}
				}
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
			visible: false //TODO
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
