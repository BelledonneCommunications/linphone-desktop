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
	property ParticipantModel me: conferenceModel.localParticipant
	property bool isMeAdmin: me && me.adminStatus
	property bool isParticipantsMenu: false
	signal close()
	
	height: 500
	width: 400
	color: "white"
	radius: VideoConferenceMenuStyle.radius
	
	// List of title texts in order to allow bindings between all components
	property var menuTitles: [
	//: 'Multimedia parameters' : Menu title to show multimedia devices configuration.
		qsTr('conferenceMenuMultimedia'),
	//: 'Change layout' : Menu title to change the conference layout.
		qsTr('conferenceMenuLayout'),
		//: 'Invite participants' : Menu title to invite participants in admin mode.
		mainItem.isMeAdmin ? qsTr('conferenceMenuInvite')
		//: 'Participants list' : Menu title to show participants in non-admin mode.
			: qsTr('conferenceMenuParticipants')
	]
	
	function showParticipantsMenu(){
		contentsStack.push(participantsMenu, {title:Qt.binding(function() { return mainItem.menuTitles[2]})})
		visible = true
	}
	
	ButtonGroup{id: modeGroup}
	ColumnLayout{
		anchors.fill: parent
// HEADER
		Borders{
			Layout.fillWidth: true
			Layout.preferredHeight: Math.max(VideoConferenceMenuStyle.header.height, titleMenu.implicitHeight+20)
			bottomColor: VideoConferenceMenuStyle.list.border.color
			bottomWidth: VideoConferenceMenuStyle.list.border.width
			RowLayout{
				anchors.fill: parent
				ActionButton{
					backgroundRadius: width/2
					isCustom: true
					colorSet: VideoConferenceMenuStyle.buttons.back
					onClicked: contentsStack.pop()
					visible: contentsStack.nViews > 1
				}
				Text{
					id: titleMenu
					text: contentsStack.currentItem.title
					Layout.fillWidth: true
					Layout.preferredHeight: implicitHeight
					horizontalAlignment: Qt.AlignCenter
					color: VideoConferenceMenuStyle.header.color
					font.pointSize: VideoConferenceMenuStyle.header.pointSize
					font.weight: VideoConferenceMenuStyle.header.weight
					wrapMode: Text.WordWrap
					elide: Text.ElideRight
				}
				ActionButton{
					Layout.rightMargin: 10
					backgroundRadius: width/2
					isCustom: true
					colorSet: VideoConferenceMenuStyle.buttons.close
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
				property string title: qsTr('conferenceMenuTitle')
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				Repeater{
					model: [
						{titleIndex: 0
						,icon: VideoConferenceMenuStyle.settingsIcons.mediaIcon
						, nextPage:mediaMenu},

						{titleIndex: 1
						, icon: (mainItem.callModel.videoEnabled ?
										(mainItem.callModel.conferenceVideoLayout == LinphoneEnums.ConferenceLayoutGrid ? VideoConferenceMenuStyle.settingsIcons.gridIcon : VideoConferenceMenuStyle.settingsIcons.activeSpeakerIcon)
									: VideoConferenceMenuStyle.settingsIcons.audioOnlyIcon)
						, nextPage:layoutMenu},

						{ titleIndex: 2
						, icon: VideoConferenceMenuStyle.settingsIcons.participantsIcon
						, nextPage:participantsMenu}
					]
					delegate:
						Borders{
						bottomColor: VideoConferenceMenuStyle.list.border.color
						bottomWidth: VideoConferenceMenuStyle.list.border.width
						Layout.preferredHeight: Math.max(settingIcon.height, settingsDescription.implicitHeight) + 20
						Layout.fillWidth: true
						RowLayout{
							anchors.fill: parent
							Icon{
								id: settingIcon
								Layout.minimumWidth: iconWidth
								Layout.leftMargin: 15
								Layout.alignment: Qt.AlignVCenter
								icon: modelData.icon
								overwriteColor: VideoConferenceMenuStyle.list.color
								iconWidth: VideoConferenceMenuStyle.settingsIcons.width
								iconHeight: VideoConferenceMenuStyle.settingsIcons.height
							}
							Text{
								id: settingsDescription
								Layout.fillWidth: true
								height: implicitHeight
								wrapMode: Text.WordWrap
								elide: Text.ElideRight
		
								text: mainItem.menuTitles[modelData.titleIndex]
								font.pointSize: VideoConferenceMenuStyle.list.pointSize
								color: VideoConferenceMenuStyle.list.color
							}
							ActionButton{
								Layout.minimumWidth: iconWidth
								Layout.rightMargin: 10
								Layout.alignment: Qt.AlignVCenter
								backgroundRadius: width/2
								isCustom: true
								colorSet: VideoConferenceMenuStyle.buttons.next
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
					model: [{text: qsTr('conferenceMenuGridLayout'), icon: VideoConferenceMenuStyle.modeIcons.gridIcon, value:LinphoneEnums.ConferenceLayoutGrid}
				//: 'Active speaker mode' : Active speaker layout for video conference.
						, {text: qsTr('conferenceMenuActiveSpeakerLayout'), icon: VideoConferenceMenuStyle.modeIcons.activeSpeakerIcon, value:LinphoneEnums.ConferenceLayoutActiveSpeaker}
				//: 'Audio only mode' : Audio only layout for video conference.
						, {text: qsTr('conferenceMenuAudioLayout'), icon: VideoConferenceMenuStyle.modeIcons.audioOnlyIcon, value:2}
					]				
					delegate:
						Borders{
						bottomColor: VideoConferenceMenuStyle.list.border.color
						bottomWidth: VideoConferenceMenuStyle.list.border.width
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
								checked: mainItem.callModel ? (mainItem.callModel.videoEnabled && modelData.value == mainItem.callModel.conferenceVideoLayout)
															|| (!mainItem.callModel.videoEnabled && modelData.value == 2)
															: false
								text: modelData.text
								onClicked: if(modelData.value == 2) mainItem.callModel.videoEnabled = false
											else mainItem.callModel.conferenceVideoLayout = modelData.value
							}
							Icon{
								id: layoutIcon							
								Layout.minimumWidth: iconWidth
								Layout.rightMargin: 10
								Layout.alignment: Qt.AlignVCenter
								icon: modelData.icon
								iconWidth: VideoConferenceMenuStyle.modeIcons.width
								iconHeight: VideoConferenceMenuStyle.modeIcons.height
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
						text: qsTr('conferenceMenuParticipantsAlone')
						visible: parent.count
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
