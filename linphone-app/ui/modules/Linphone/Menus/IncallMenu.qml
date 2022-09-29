import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.12
import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import LinphoneEnums 1.0

import UtilsCpp 1.0

import App.Styles 1.0

// =============================================================================

Rectangle{
	id: mainItem
	property CallModel callModel
	property ConferenceModel conferenceModel: callModel.conferenceModel
	property ParticipantModel me: conferenceModel ? conferenceModel.localParticipant : null
	property bool isMeAdmin: me && me.adminStatus
	property bool isParticipantsMenu: false
	signal close()
	signal layoutChanging(int layoutMode)
	
	height: 500
	width: 400
	color: "white"
	radius: IncallMenuStyle.radius
	
	// List of title texts in order to allow bindings between all components
	property var menuTitles: [
	//: 'Multimedia parameters' : Menu title to show multimedia devices configuration.
		qsTr('incallMenuMultimedia'),
	//: 'Change layout' : Menu title to change the conference layout.
		qsTr('incallMenuLayout'),
		//: 'Invite participants' : Menu title to invite participants in admin mode.
		mainItem.isMeAdmin ? qsTr('incallMenuInvite')
		//: 'Participants list' : Menu title to show participants in non-admin mode.
			: qsTr('incallMenuParticipants')
	]
	
	function showParticipantsMenu(){
		contentsStack.push(participantsMenu, {title:Qt.binding(function() { return mainItem.menuTitles[2]})})
		visible = true
	}
	onVisibleChanged: if(!visible && contentsStack.nViews > 1) {
		contentsStack.pop()
	}
	ButtonGroup{id: modeGroup}
	ColumnLayout{
		anchors.fill: parent
// HEADER
		Borders{
			Layout.fillWidth: true
			Layout.preferredHeight: Math.max(IncallMenuStyle.header.height, titleMenu.implicitHeight+20)
			bottomColor: IncallMenuStyle.list.border.color
			bottomWidth: IncallMenuStyle.list.border.width
			RowLayout{
				anchors.fill: parent
				ActionButton{
					backgroundRadius: width/2
					isCustom: true
					colorSet: IncallMenuStyle.buttons.back
					onClicked: contentsStack.pop()
					visible: contentsStack.nViews > 1
				}
				Text{
					id: titleMenu
					text: contentsStack.currentItem.title
					Layout.fillWidth: true
					Layout.preferredHeight: implicitHeight
					horizontalAlignment: Qt.AlignCenter
					color: IncallMenuStyle.header.color
					font.pointSize: IncallMenuStyle.header.pointSize
					font.weight: IncallMenuStyle.header.weight
					wrapMode: Text.WordWrap
					elide: Text.ElideRight
				}
				ActionButton{
					Layout.rightMargin: 10
					backgroundRadius: width/2
					isCustom: true
					colorSet: IncallMenuStyle.buttons.close
					onClicked: mainItem.close()
				}
			}
		}
// CONTENT
		StackView{
			id: contentsStack
			initialItem: settingsMenuComponent
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
		Component{
			id: settingsMenuComponent
			ColumnLayout{
				property string objectName: 'settingsMenu'
				//: 'Settings' : Main menu title for settings.
				property string title: qsTr('incallMenuTitle')
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				Repeater{
					model: [
						{titleIndex: 0
						,icon: IncallMenuStyle.settingsIcons.mediaIcon
						, nextPage:mediaMenu
						, visible: true},
						
						{titleIndex: 1
						, icon: (mainItem.callModel && mainItem.callModel.localVideoEnabled ?
										(mainItem.callModel.conferenceVideoLayout == LinphoneEnums.ConferenceLayoutGrid ? IncallMenuStyle.settingsIcons.gridIcon : IncallMenuStyle.settingsIcons.activeSpeakerIcon)
									: IncallMenuStyle.settingsIcons.audioOnlyIcon)
						, nextPage:layoutMenu
						, visible: mainItem.callModel && mainItem.callModel.isConference},

						{ titleIndex: 2
						, icon: IncallMenuStyle.settingsIcons.participantsIcon
						, nextPage:participantsMenu
						, visible: mainItem.callModel && mainItem.callModel.isConference}
					]
					delegate:
						Borders{
						bottomColor: IncallMenuStyle.list.border.color
						bottomWidth: IncallMenuStyle.list.border.width
						Layout.preferredHeight: Math.max(settingIcon.height, settingsDescription.implicitHeight) + 20
						Layout.fillWidth: true
						visible: modelData.visible
						RowLayout{
							anchors.fill: parent
							Icon{
								id: settingIcon
								Layout.minimumWidth: iconWidth
								Layout.leftMargin: 15
								Layout.alignment: Qt.AlignVCenter
								icon: modelData.icon
								overwriteColor: IncallMenuStyle.list.color
								iconWidth: IncallMenuStyle.settingsIcons.width
								iconHeight: IncallMenuStyle.settingsIcons.height
							}
							Text{
								id: settingsDescription
								Layout.fillWidth: true
								height: implicitHeight
								wrapMode: Text.WordWrap
								elide: Text.ElideRight
		
								text: mainItem.menuTitles[modelData.titleIndex]
								font.pointSize: IncallMenuStyle.list.pointSize
								color: IncallMenuStyle.list.color
							}
							ActionButton{
								Layout.minimumWidth: iconWidth
								Layout.rightMargin: 10
								Layout.alignment: Qt.AlignVCenter
								backgroundRadius: width/2
								isCustom: true
								colorSet: IncallMenuStyle.buttons.next
							}
						}
						MouseArea{
							anchors.fill: parent
							onClicked: {
								contentsStack.push(modelData.nextPage, {title:Qt.binding(function() { return settingsDescription.text})})
							}
						}
					}
				}
				Item{// Spacer
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
			}
		}
//-----------------------------------------------------------------------------------------------------------------------------
		Component{
			id: mediaMenu
			ColumnLayout{
				property string title
				Layout.fillHeight: true
				Layout.fillWidth: true
				MultimediaParametersDialog{
					Layout.fillHeight: true
					Layout.fillWidth: true
					Layout.minimumHeight: fitHeight
					call: conference.callModel
					flat: true
					showMargins: true
					expandHeight: false
					fixedSize: false
					showTitleBar: false
					onExitStatus: contentsStack.pop()
				}
				Item{// Spacer
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
			}
		}
//-----------------------------------------------------------------------------------------------------------------------------
		Component{
			id: layoutMenu
			ColumnLayout{
				property string title
				Layout.fillHeight: true
				Layout.fillWidth: true
				Repeater{
				//: 'Mosaic mode' : Grid layout for video conference.
					model: [{text: qsTr('incallMenuGridLayout'), icon: IncallMenuStyle.modeIcons.gridIcon, value:LinphoneEnums.ConferenceLayoutGrid}
				//: 'Active speaker mode' : Active speaker layout for video conference.
						, {text: qsTr('incallMenuActiveSpeakerLayout'), icon: IncallMenuStyle.modeIcons.activeSpeakerIcon, value:LinphoneEnums.ConferenceLayoutActiveSpeaker}
				//: 'Audio only mode' : Audio only layout for video conference.
						, {text: qsTr('incallMenuAudioLayout'), icon: IncallMenuStyle.modeIcons.audioOnlyIcon, value:2}
					]				
					delegate:
						Borders{
						bottomColor: IncallMenuStyle.list.border.color
						bottomWidth: IncallMenuStyle.list.border.width
						Layout.preferredHeight: Math.max(layoutIcon.height, radio.contentItem.implicitHeight) + 20
						Layout.fillWidth: true
						RowLayout{
							anchors.fill: parent
							
							RadioButton{
								id: radio
								Layout.fillWidth: true
								Layout.leftMargin: 15
								Layout.preferredHeight: contentItem.implicitHeight
								Layout.alignment: Qt.AlignVCenter
								ButtonGroup.group: modeGroup
								text: modelData.text
								
								property bool isInternallyChecked: mainItem.callModel ? (mainItem.callModel.localVideoEnabled && modelData.value == mainItem.callModel.conferenceVideoLayout)
															|| (!mainItem.callModel.localVideoEnabled && modelData.value == 2)
															: false
								// break bind. Radiobutton checked itself without taking care of custom binding. This workaound works as long as we don't really need the binding.
								onIsInternallyCheckedChanged: checked = isInternallyChecked
								Component.onCompleted: checked = isInternallyChecked
								Timer{
									id: changingLayoutDelay
									interval: 100
									onTriggered: {if(modelData.value == 2) mainItem.callModel.videoEnabled = false
												else {
													mainItem.callModel.conferenceVideoLayout = modelData.value
													mainItem.callModel.videoEnabled = true
												}
												mainItem.enabled = true
											}
								}
								onClicked:{
								// Do changes only if we choose a different layout.
											if(! ( mainItem.callModel ? (mainItem.callModel.localVideoEnabled && modelData.value == mainItem.callModel.conferenceVideoLayout)
															|| (!mainItem.callModel.localVideoEnabled && modelData.value == 2)
															: false)){
												mainItem.enabled = false
												mainItem.layoutChanging(modelData.value)// Let time to clear cameras
												changingLayoutDelay.start()
											}
										}
							}
							Icon{
								id: layoutIcon							
								Layout.minimumWidth: iconWidth
								Layout.rightMargin: 10
								Layout.alignment: Qt.AlignVCenter
								icon: modelData.icon
								iconWidth: IncallMenuStyle.modeIcons.width
								iconHeight: IncallMenuStyle.modeIcons.height
							}
						}
					}
				}
				Item{// Spacer
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
			}
		}
//-----------------------------------------------------------------------------------------------------------------------------
		Component{
			id: participantsMenu
			ColumnLayout{
				property string title
				Layout.fillHeight: true
				Layout.fillWidth: true
				ParticipantsListView{
					Layout.fillHeight: true
					Layout.fillWidth: true
					Layout.leftMargin: 10
					Layout.rightMargin: 10
					conferenceModel: mainItem.conferenceModel
					isAdmin: mainItem.isMeAdmin
					Text{
					//: 'Your are currently alone in this conference' : Message to warn the user when there is no other participant.
						text: qsTr('incallMenuParticipantsAlone')
						visible: parent.count <= 1
						font.pointSize: IncallMenuStyle.list.pointSize
						color: IncallMenuStyle.list.color
					}
				}
				Item{// Spacer
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
				Component.onCompleted: mainItem.isParticipantsMenu = true
				Component.onDestruction: mainItem.isParticipantsMenu = false
			}
		}
	}
}
