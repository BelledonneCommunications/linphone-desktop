import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.12

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import UtilsCpp 1.0

import App.Styles 1.0


// Temp
import 'Incall.js' as Logic

// =============================================================================

Rectangle {
	id: conference
	
	property CallModel callModel
	property var _fullscreen: null
	/*
	onCallModelChanged: if(callModel) {
							grid.setParticipantDevicesMode()
						}else
							grid.setTestMode()
							*/
	// ---------------------------------------------------------------------------
	
	color: VideoConferenceStyle.backgroundColor
	/*
	Component.onCompleted: {
			if(!callModel){
				grid.setTestMode()
			}else
				grid.setParticipantDevicesMode()
		}
		*/
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
			}
			ActionButton{
				isCustom: true
				backgroundRadius: width/2
				colorSet: VideoConferenceStyle.buttons.dialpad
			}
// Title
			Text{
				horizontalAlignment: Qt.AlignHCenter
				Layout.fillWidth: true
				text: 'Sujet de la conférence' + ' - ' + '02:23:12'
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
						onCurrentDeviceChanged: console.log("currentDevice changed: " +currentDevice +", me:"+currentDevice.isMe+" ["+index+"]")
						color: /*!conference.callModel && gridModel.defaultList.get(index).color ? gridModel.defaultList.get(index).color : */'#AAAAAAAA'
						//color: gridModel.model.get(index) && gridModel.model.get(index).color ? gridModel.model.get(index).color : ''	// modelIndex is a custom index because by Mosaic modelisation, it is not accessible.
						//color:  modelData.color ? modelData.color : ''
						radius: grid.radius
						height: grid.cellHeight - 5
						width: grid.cellWidth - 5
						Component.onCompleted: console.log("Completed: ["+index+"] " +currentDevice.peerAddress+", isMe:"+currentDevice.isMe)
						
						Item {
							id: container
							anchors.fill: parent
							anchors.margins: CallStyle.container.margins
							visible: conference.callModel 
							//Layout.fillWidth: true
							//Layout.fillHeight: true
							//Layout.margins: CallStyle.container.margins
							
							Component {
								id: avatar
								
								IncallAvatar {
									//call: gridModel.participantDevices.get(index).call
									participantDeviceModel: avatarCell.currentDevice
									height: Logic.computeAvatarSize(container, CallStyle.container.avatar.maxSize)
									width: height
									Component.onCompleted: console.log("Avatar completed"+ " ["+index+"]")
									Component.onDestruction: console.log("Avatar destroyed"+ " ["+index+"]")
								}
							}
							Loader {
								anchors.centerIn: parent
								
								active: avatarCell.currentDevice && !avatarCell.currentDevice.isMe && (!avatarCell.currentDevice.videoEnabled || conference._fullscreen)
								sourceComponent: avatar
							}
							Loader {
								id: cameraLoader
								
								//anchors.centerIn: parent
								anchors.fill: parent
								property bool isVideoEnabled : avatarCell.currentDevice && avatarCell.currentDevice.videoEnabled
								property bool t_fullscreen: conference._fullscreen
								property bool tCallModel: conference.callModel
								property bool resetActive: false
								onIsVideoEnabledChanged: console.log("Video is enabled : " +isVideoEnabled + " ["+index+"]")
								onT_fullscreenChanged: console.log("_fullscreen changed: " +t_fullscreen+ " ["+index+"]")
								onTCallModelChanged: console.log("CallModel changed: " +tCallModel+ " ["+index+"]")
								
								active: !resetActive //avatarCell.currentDevice && (avatarCell.currentDevice.videoEnabled && !conference._fullscreen)
								onActiveChanged: {console.log("Active Changed: "+active+ " ["+index+"]")
									if(!active && resetActive){
										resetActive = false
										active = true
									}
								}
								property int cameraMode: avatarCell.currentDevice ? 
																		avatarCell.currentDevice.isMe ? 1
																			:  2
																	 : 0
								sourceComponent: cameraMode == 1 ? cameraPreview : cameraMode == 2 ? camera : null
								onSourceComponentChanged: console.log("SourceComponent Changed: "+cameraMode+ " ["+index+"]")
																	 
								
								Component {
									id: camera
									
									Camera {
										//call: grid.get(modelIndex).call
										participantDeviceModel: avatarCell.currentDevice
										//height: container.height
										//width: container.width
										anchors.fill: parent
										onRequestNewRenderer: {cameraLoader.resetActive = true}
										
										Component.onCompleted: console.log("Camera completed"+ " ["+index+"]")
										Component.onDestruction: console.log("Camera destroyed"+ " ["+index+"]")
									}
								}
								Component {
									id: cameraPreview
									
									Camera {
										anchors.fill: parent
										//participantDeviceModel: avatarCell.currentDevice
										isPreview: true
										onRequestNewRenderer: {cameraLoader.resetActive = true}
										
										Component.onCompleted: console.log("Preview completed"+ " ["+index+"]")
										Component.onDestruction: console.log("Preview destroyed"+ " ["+index+"]")
									}
								}
							}
							Rectangle{
								anchors.fill: parent
								color: avatarCell.currentDevice.isMe ? '#09FF0000' : '#0900FF00'
							}
						}
						MouseArea{
							anchors.fill: parent
							onClicked: {grid.remove( index)}
						}
					}
				}
			}
		}
		
		/*
		GridLayout {
			id: grid
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.leftMargin: 70
			Layout.rightMargin: 70
			Layout.topMargin: 15
			Layout.bottomMargin: 20
			Layout.alignment: Qt.AlignCenter
			
			columns: 3
			property int radius : 8
			Rectangle{
				Layout.fillHeight: true
				Layout.fillWidth: true
				color: 'red'
				radius: parent.radius
			}
			Rectangle{
				Layout.fillHeight: true
				Layout.fillWidth: true
				color: 'green'
				radius: parent.radius
			}
			Rectangle{
				Layout.fillHeight: true
				Layout.fillWidth: true
				color: 'orange'
				radius: parent.radius
			}
			Rectangle{
				Layout.fillHeight: true
				Layout.fillWidth: true
				color: 'yellow'
				radius: parent.radius
			}
			Rectangle{
				Layout.fillHeight: true
				Layout.fillWidth: true
				Layout.columnSpan: 2
				color: 'blue'
				radius: parent.radius
			}
			Rectangle{
				Layout.fillHeight: true
				Layout.fillWidth: true
				color: 'pink'
				radius: parent.radius
			}
		}
		*/
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
				spacing: 10
				RowLayout{
					Row {
						spacing: 2
						
						VuMeter {
							Timer {
								interval: 50
								repeat: true
							}
						}
						ActionSwitch {
							id: micro
							isCustom: true
							backgroundRadius: 90
							colorSet: enabled ? VideoConferenceStyle.buttons.microOn : VideoConferenceStyle.buttons.microOff
						}
					}
					Row {
						spacing: 2
						
						VuMeter {
							Timer {
								interval: 50
								repeat: true
							}
						}
						ActionSwitch {
							id: speaker
							isCustom: true
							backgroundRadius: 90
							colorSet: enabled ? VideoConferenceStyle.buttons.speakerOn : VideoConferenceStyle.buttons.speakerOff
						}
					}
					ActionSwitch {
						id: camera
						isCustom: true
						backgroundRadius: 90
						colorSet: conference.callModel && conference.callModel.videoEnabled  ? VideoConferenceStyle.buttons.cameraOn : VideoConferenceStyle.buttons.cameraOff
						//updating: conference.callModel.videoEnabled && conference.callModel.updating
						onClicked: if(conference.callModel) conference.callModel.videoEnabled = !conference.callModel.videoEnabled
					}
				}
				RowLayout{
					ActionButton{
						isCustom: true
						backgroundRadius: width/2
						colorSet: VideoConferenceStyle.buttons.pause
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
					
					//onClicked: Logic.openCallStatistics()
					
					// See: http://www.linphone.org/docs/liblinphone/group__call__misc.html#ga62c7d3d08531b0cc634b797e273a0a73
					Timer {
						interval: 500
						repeat: true
						running: true
						triggeredOnStart: true
						
						onTriggered: {
							callQuality.percentageDisplayed = (callQuality.percentageDisplayed + 10 ) % 110
						/*
									// Note: `quality` is in the [0, 5] interval and -1.
									var quality = call.quality
									if(quality >= 0)
										callQuality.percentageDisplayed = quality * 100 / 5
									else
										callQuality.percentageDisplayed = 0
*/
							}						
					}
					/*
					CallStatistics {
						id: callStatistics
						
						call: incall.call
						width: container.width
						
						relativeTo: callQuality
						relativeY: CallStyle.header.stats.relativeY
						
						onClosed: Logic.handleCallStatisticsClosed()
					}*/
				}
				ActionButton{
					isCustom: true
					backgroundRadius: width/2
					colorSet: VideoConferenceStyle.buttons.options
				}
			}
		}
	}
}
