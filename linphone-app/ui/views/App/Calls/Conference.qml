import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0

import UtilsCpp 1.0

import App.Styles 1.0

// =============================================================================

Rectangle {
	id: conference
	
	property var conferenceModel
	
	// ---------------------------------------------------------------------------
	
	color: CallStyle.backgroundColor.color
	
	// ---------------------------------------------------------------------------
	
	ColumnLayout {
		anchors {
			fill: parent
			topMargin: CallStyle.header.topMargin
		}
		
		spacing: 0
		
		// -------------------------------------------------------------------------
		// Conference info.
		// -------------------------------------------------------------------------
		
		Item {
			id: info
			
			Layout.fillWidth: true
			Layout.leftMargin: CallStyle.header.leftMargin
			Layout.rightMargin: CallStyle.header.rightMargin
			Layout.preferredHeight: ConferenceStyle.description.height
			
			ActionBar {
				id: leftActions
				
				anchors.left: parent.left
				iconSize: CallStyle.header.iconSize
			}
			
			Text {
				id: conferenceDescription
				
				anchors.centerIn: parent
				
				horizontalAlignment: Text.AlignHCenter
				text: qsTr('conferenceTitle')
				
				color: ConferenceStyle.description.colorModel.color
				
				font {
					bold: true
					pointSize: ConferenceStyle.description.pointSize
				}
				
				height: parent.height
				width: parent.width - rightActions.width - leftActions.width - ConferenceStyle.description.width
			}
			
			
			// -----------------------------------------------------------------------
			// Video actions.
			// -----------------------------------------------------------------------
			
			ActionBar {
				id: rightActions
				
				anchors.right: parent.right
				iconSize: CallStyle.header.buttonIconSize
				
				ActionButton {
					isCustom: true
					backgroundRadius: 90
					property bool recording: conference.conferenceModel.recording
					colorSet: recording ? CallStyle.buttons.recordOn : CallStyle.buttons.recordOff
					visible: SettingsModel.callRecorderEnabled
					
					onClicked: !recording
							   ? conference.conferenceModel.startRecording()
							   : conference.conferenceModel.stopRecording()
				}
			}
		}
		
		// -------------------------------------------------------------------------
		// Contacts visual.
		// -------------------------------------------------------------------------
		
		Item {
			id: container
			
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.margins: CallStyle.container.margins
			
			GridView {
				id: grid
				
				anchors.fill: parent
				
				cellHeight: ConferenceStyle.grid.cell.height
				cellWidth: ConferenceStyle.grid.cell.width
				
				model: conference.conferenceModel
				
				delegate: Item {
					height: grid.cellHeight
					width: grid.cellWidth
					
					Column {
						readonly property string sipAddress: $modelData.peerAddress
						property var _sipAddressObserver : SipAddressesModel.getSipAddressObserver($modelData.peerAddress, $modelData.localAddress)
						
						anchors {
							fill: parent
							margins: ConferenceStyle.grid.spacing
						}
						
						spacing: ConferenceStyle.grid.cell.spacing
						
						Component.onDestruction: _sipAddressObserver=null// Need to set it to null because of not calling destructor if not.
						ContactDescription {
							id: contactDescription
							
							height: ConferenceStyle.grid.cell.contactDescription.height
							width: parent.width
							
							horizontalTextAlignment: Text.AlignHCenter
							subtitleText: UtilsCpp.toDisplayString(SipAddressesModel.cleanSipAddress(parent.sipAddress), SettingsModel.sipDisplayMode)
							titleText: parent._sipAddressObserver ? UtilsCpp.getDisplayName(parent._sipAddressObserver.peerAddress) : ''
						}
						IncallAvatar {
							
							readonly property int size: Math.min(
															parent.width,
															parent.height - contactDescription.height - parent.spacing
															)
							
							anchors.horizontalCenter: parent.horizontalCenter
							call: $modelData
							onCallChanged: if(!call) conference.conferenceModel.invalidate()
							
							height: size
							width: size
							
							BusyIndicator {
								anchors {
									horizontalCenter: parent.horizontalCenter
									verticalCenter: parent.verticalCenter
								}
								
								color: CallStyle.header.busyIndicator.colorModel.color
								height: CallStyle.header.busyIndicator.height
								width: CallStyle.header.busyIndicator.width
								
								visible: $modelData && $modelData.status === CallModel.CallStatusOutgoing
							}
						}
					}
					
					VuMeter {
						anchors {
							bottom: parent.bottom
							left: parent.left
							leftMargin: ConferenceStyle.grid.spacing
							bottomMargin: ConferenceStyle.grid.spacing
						}
						enabled:!$modelData.speakerMuted
						
						Timer {
							interval: 50
							repeat: true
							running: true
							onTriggered: parent.value = $modelData.speakerVu
						}
					}
					MouseArea{
						anchors.fill:parent
						onClicked:$modelData.toggleSpeakerMute()
					}
				}
			}
		}
		
		// -------------------------------------------------------------------------
		// Action Buttons.
		// -------------------------------------------------------------------------
		
		Item {
			Layout.fillWidth: true
			Layout.preferredHeight: CallStyle.actionArea.height
			
			GridLayout {
				anchors {
					left: parent.left
					leftMargin: CallStyle.actionArea.leftButtonsGroupMargin
					verticalCenter: parent.verticalCenter
				}
				
				columns: incall.width < CallStyle.actionArea.lowWidth ? 2 : 4
				rowSpacing: ActionBarStyle.spacing
				
				Row {
					spacing: CallStyle.actionArea.vu.spacing
					
					VuMeter {
						Timer {
							interval: 50
							repeat: true
							running: micro.enabled
							
							onTriggered: parent.value = conference.conferenceModel.microVu
						}
						
						enabled: micro.enabled
					}
					
					ActionSwitch {
						id: micro
						isCustom: true
						backgroundRadius: 90
						colorSet: enabled ? CallStyle.buttons.microOn : CallStyle.buttons.microOff
						enabled: !conference.conferenceModel.microMuted
						
						onClicked: conference.conferenceModel.microMuted = !conference.conferenceModel.microMuted
					}
				}
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
					colorSet: !conference.conferenceModel.isInConf ? CallStyle.buttons.play : CallStyle.buttons.pause
										
					onClicked: {
						var model = conference.conferenceModel
						if (model.isInConf) {
							model.leave()
						} else {
							model.join()
						}
					}
				}
				
				ActionButton {
					isCustom: true
					backgroundRadius: 90
					colorSet: CallStyle.buttons.hangup
					
					onClicked: conference.conferenceModel.terminate()
				}
			}
		}
	}
}
