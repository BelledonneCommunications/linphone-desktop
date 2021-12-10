import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import UtilsCpp 1.0

import App.Styles 1.0

// =============================================================================

Rectangle {
	id: conference
	
	property CallModel callModel
	
	// ---------------------------------------------------------------------------
	
	color: VideoConferenceStyle.backgroundColor
	
	Component.onCompleted: {
			for(var i = 0 ; i < 5 ; ++i)
				grid.add({color:  '#'+ Math.floor(Math.random()*255).toString(16)
										+Math.floor(Math.random()*255).toString(16)
										+Math.floor(Math.random()*255).toString(16)})
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
				
				delegate: 
				Rectangle{
					color: grid.get(modelIndex) && grid.get(modelIndex).color ? grid.get(modelIndex).color : ''	// modelIndex is a custom index because by Mosaic modelisation, it is not accessible.
					radius: grid.radius
					/*
					Item {
						id: container
						
						Layout.fillWidth: true
						Layout.fillHeight: true
						Layout.margins: CallStyle.container.margins
						
						Component {
							id: avatar
							
							IncallAvatar {
								call: grid.get(modelIndex).call
								height: Logic.computeAvatarSize(CallStyle.container.avatar.maxSize)
								width: height
							}
						}
						
						Loader {
							id: cameraLoader
							
							anchors.centerIn: parent
							
							active: incall.call.videoEnabled && !_fullscreen
							sourceComponent: camera
							
							Component {
								id: camera
								
								Camera {
									call: grid.get(modelIndex).call
									height: container.height
									width: container.width
								}
							}
						}
						
						Loader {
							anchors.centerIn: parent
							
							active: !grid.get(modelIndex).call.videoEnabled || _fullscreen
							sourceComponent: avatar
						}
					}*/
					MouseArea{
						anchors.fill: parent
						onClicked: {grid.remove( modelIndex)}
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
						colorSet: enabled ? VideoConferenceStyle.buttons.cameraOn : VideoConferenceStyle.buttons.cameraOff
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
