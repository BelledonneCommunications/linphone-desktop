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
import DesktopTools 1.0

import App.Styles 1.0

// =============================================================================

Rectangle{
	id: mainItem
	property CallModel callModel
	property ConferenceModel conferenceModel: callModel.conferenceModel
	property ParticipantModel me: conferenceModel ? conferenceModel.localParticipant : null
	property bool isMeAdmin: me && me.adminStatus
	property bool isParticipantsMenu: false
	property bool isScreenSharingMenu: false
	property bool screenSharingAvailable: conferenceModel && (!conferenceModel.isScreenSharingEnabled || conferenceModel.isLocalScreenSharingEnabled)
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
			: qsTr('incallMenuParticipants'),
		//: 'Screen Sharing' : Menu title to show the screen sharing settings.
			qsTr('incallMenuScreenSharing')
	]
	
	function showParticipantsMenu(){
		contentsStack.push(participantsMenu, {title:Qt.binding(function() { return mainItem.menuTitles[2]})})
		visible = true
	}
	function showScreenSharingMenu(){
		contentsStack.push(screenSharingMenu, {title:Qt.binding(function() { return mainItem.menuTitles[3]})})
		visible = true
	}
	onVisibleChanged: if(!visible && contentsStack.nViews > 1) {
		contentsStack.pop()
	}
	property bool _activateCamera: false
	Connections{// Enable camera only when status is ok
		target: mainItem.callModel
		onStatusChanged: if( mainItem._activateCamera && (status == CallModel.CallStatusConnected || status == CallModel.CallStatusIdle)){
			camera._activateCamera = false
			callModel.cameraEnabled = true
		}
	}
	ButtonGroup{id: modeGroup}
	ButtonGroup{id: screenSharingGroup}
	ColumnLayout{
		anchors.fill: parent
// HEADER
		Borders{
			Layout.fillWidth: true
			Layout.preferredHeight: Math.max(IncallMenuStyle.header.height, titleMenu.implicitHeight+20)
			bottomColor: IncallMenuStyle.list.border.colorModel.color
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
					color: IncallMenuStyle.header.colorModel.color
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
						, icon: (mainItem.callModel
								? mainItem.callModel.conferenceVideoLayout == LinphoneEnums.ConferenceLayoutAudioOnly
									? IncallMenuStyle.settingsIcons.audioOnlyIcon
									: mainItem.callModel.conferenceVideoLayout == LinphoneEnums.ConferenceLayoutGrid
										? IncallMenuStyle.settingsIcons.gridIcon
										: IncallMenuStyle.settingsIcons.activeSpeakerIcon
								: IncallMenuStyle.settingsIcons.audioOnlyIcon)
						, nextPage:layoutMenu
						, visible: mainItem.callModel && mainItem.callModel.isConference && SettingsModel.videoAvailable},

						{ titleIndex: 2
						, icon: IncallMenuStyle.settingsIcons.participantsIcon
						, nextPage:participantsMenu
						, visible: mainItem.callModel && mainItem.callModel.isConference},
						
						{ titleIndex: 3
						, icon: IncallMenuStyle.settingsIcons.screenSharingIcon
						, nextPage: screenSharingMenu
						, visible: mainItem.screenSharingAvailable && SettingsModel.videoAvailable}
					]
					delegate:
						Borders{
						bottomColor: IncallMenuStyle.list.border.colorModel.color
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
								overwriteColor: IncallMenuStyle.list.colorModel.color
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
								color: IncallMenuStyle.list.colorModel.color
							}
							Icon{
								Layout.minimumWidth: iconWidth
								Layout.rightMargin: 10
								Layout.alignment: Qt.AlignVCenter
								//backgroundRadius: width/2
								
								icon: IncallMenuStyle.buttons.next.icon
								overwriteColor: IncallMenuStyle.buttons.next.backgroundNormalColor.color
								iconWidth: IncallMenuStyle.buttons.next.iconSize
								iconHeight: IncallMenuStyle.buttons.next.iconSize
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
					call: mainItem.callModel
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
					model: [{text: qsTr('incallMenuGridLayout'), icon: IncallMenuStyle.modeIcons.gridIcon, value:LinphoneEnums.ConferenceLayoutGrid, enabled: (!mainItem.conferenceModel 
					|| (mainItem.conferenceModel.participantDeviceCount <= SettingsModel.conferenceMaxThumbnails+1 && !mainItem.conferenceModel.isScreenSharingEnabled))}
				//: 'Active speaker mode' : Active speaker layout for video conference.
						, {text: qsTr('incallMenuActiveSpeakerLayout'), icon: IncallMenuStyle.modeIcons.activeSpeakerIcon, value:LinphoneEnums.ConferenceLayoutActiveSpeaker, enabled: true}
				//: 'Audio only mode' : Audio only layout for video conference.
						, {text: qsTr('incallMenuAudioLayout'), icon: IncallMenuStyle.modeIcons.audioOnlyIcon, value:LinphoneEnums.ConferenceLayoutAudioOnly, enabled: true}
					]				
					delegate:
						Borders{
						bottomColor: IncallMenuStyle.list.border.colorModel.color
						bottomWidth: IncallMenuStyle.list.border.width
						Layout.preferredHeight: Math.max(layoutIcon.height, radio.contentItem.implicitHeight) + 20
						Layout.fillWidth: true
						enabled: mainItem.callModel && !mainItem.callModel.updating && modelData.enabled
						opacity: enabled ? 1.0 : 0.5
						MouseArea{
							anchors.fill: parent
							onClicked: radio.clicked()
						}
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
															|| (!mainItem.callModel.localVideoEnabled && modelData.value == LinphoneEnums.ConferenceLayoutAudioOnly)
															: false
								// break bind. Radiobutton checked itself without taking care of custom binding. This workaound works as long as we don't really need the binding.
								onIsInternallyCheckedChanged: checked = isInternallyChecked
								Component.onCompleted: checked = isInternallyChecked
								onClicked: mainItem.layoutChanging(modelData.value)
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
					//: 'Your are currently alone in this meeting' : Message to warn the user when there is no other participant.
						text: qsTr('incallMenuParticipantsAlone')
						visible: parent.count <= 1
						font.pointSize: IncallMenuStyle.list.pointSize
						color: IncallMenuStyle.list.colorModel.color
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
//-----------------------------------------------------------------------------------------------------------------------------
		Component{
			id: screenSharingMenu
			ColumnLayout{
				id: screenSharingItem
				property VideoSourceDescriptorModel desc: mainItem.callModel.videoSourceDescriptorModel
				property string title
				Layout.fillHeight: true
				Layout.fillWidth: true
				RadioButton{
					id: displayRadioButton
					Layout.fillWidth: true
					Layout.leftMargin: 15
					//: 'Entire screen' : Setting label to set the mode of screen sharing for displaying a selected screen.
					text: qsTr('incallMenuScreenSharingScreen')
					font.pointSize: IncallMenuStyle.list.pointSize
					ButtonGroup.group: screenSharingGroup
					checked: screenSharingItem.desc && screenSharingItem.desc.isScreenSharing && screenSharingItem.desc.screenSharingType == LinphoneEnums.VideoSourceScreenSharingTypeDisplay
					onClicked: {
						screenSharingItem.desc.screenSharingIndex = 0
						if( mainItem.conferenceModel.isLocalScreenSharingEnabled)
							mainItem.callModel.setVideoSourceDescriptorModel(screenSharingItem.desc)
					}
				}
				
				ListView{
					id: screenList
					property int selectedIndex: displayRadioButton.checked ? screenSharingItem.desc.screenSharingIndex : -1
					Layout.fillWidth: true
					Layout.leftMargin: 15
					Layout.preferredWidth: parent.width
					Layout.preferredHeight: 100
					orientation: ListView.Horizontal
					model: ScreenProxyModel{}
					spacing: 10
					delegate:Rectangle{
						width: 114 + 10
						height: 100
						border.color: 'red'
						border.width: index == screenList.selectedIndex ? 1 : 0
						radius: 10
						ColumnLayout{
							anchors.fill: parent
							anchors.margins: 5
							RoundedImage{
								Layout.preferredWidth: 114
								Layout.preferredHeight: 64
								backgroundColor: 'white'
								source: 'image://screen/'+index
								radius: 10
								cache: false
							}
							Text{
								Layout.fillWidth: true
								text: modelData.name != ''
										? modelData.name
										//: 'Screen %1' : Screen enumeration for selection where %1 is the index of the screen.
										: qsTr('incallMenuScreenSharingScreenIndex').arg(index+1)
								font.pointSize: IncallMenuStyle.list.pointSize
								color: IncallMenuStyle.list.colorModel.color
								horizontalAlignment: Text.AlignHCenter
								verticalAlignment: Text.AlignVCenter
							}
						}
						MouseArea{
							anchors.fill: parent
							onClicked: {
								screenSharingItem.desc.screenSharingIndex = index
								if( mainItem.conferenceModel.isLocalScreenSharingEnabled)
									 mainItem.callModel.setVideoSourceDescriptorModel(screenSharingItem.desc)
							}
						}
					}
				}
				Rectangle{
					Layout.fillWidth: true
					Layout.preferredHeight: IncallMenuStyle.list.border.width
					color: IncallMenuStyle.list.border.colorModel.color
				}
				RadioButton{
					id: windowSharingRadioButton
					Layout.fillWidth: true
					Layout.leftMargin: 15
					//: 'Window' : Setting label to set the mode of the screen sharing for displaying a selected window.
					text: qsTr('incalMenuScreenSharingWindow')
					font.pointSize: IncallMenuStyle.list.pointSize
					ButtonGroup.group: screenSharingGroup
					checked: screenSharingItem.desc && screenSharingItem.desc.isScreenSharing && screenSharingItem.desc.screenSharingType == LinphoneEnums.VideoSourceScreenSharingTypeWindow//screenList.selectedIndex < 0
					onClicked: DesktopTools.getWindowIdFromMouse(screenSharingItem.desc)
					Connections{
						target: DesktopTools
						onWindowIdSelectionEnded: if( mainItem.conferenceModel.isLocalScreenSharingEnabled)
									 mainItem.callModel.setVideoSourceDescriptorModel(screenSharingItem.desc)
					}
				}
				
				RoundedImage{
					visible: windowSharingRadioButton.checked
					Layout.leftMargin: 15
					Layout.preferredWidth: 114
					Layout.preferredHeight: 64
					backgroundColor: 'white'
					source: windowSharingRadioButton.checked ? 'image://window/'+screenSharingItem.desc.windowId : ''
					radius: 10
					cache: false
				}
							
				Rectangle{
					Layout.fillWidth: true
					Layout.preferredHeight: IncallMenuStyle.list.border.width
					color: IncallMenuStyle.list.border.colorModel.color
				}
				Item{// Spacer
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
				Item{// Item encapsulation because of a bug on width update when changing text
					Layout.fillWidth: true
					Layout.preferredHeight: screenSharingButton.fitHeight
					Layout.margins: 20
					TextButtonB{
						id: screenSharingButton
						anchors.fill: parent
						visible: mainItem.screenSharingAvailable
						enabled: displayRadioButton.checked || windowSharingRadioButton.checked
						text: mainItem.conferenceModel && mainItem.conferenceModel.isLocalScreenSharingEnabled
						//: 'Stop' : Text button to stop the screen sharing.
								? qsTr('incallMenuScreenSharingStop')
						//: 'Share' : Text button to start the screen sharing.
								: qsTr('incallMenuScreenSharingStart')
						capitalization: Font.AllUppercase
						onClicked: mainItem.conferenceModel.toggleScreenSharing()
						Connections{
							target: mainItem.conferenceModel
							onLocalScreenSharingChanged: (enabled) => {if(enabled) mainItem.callModel.setVideoSourceDescriptorModel(screenSharingItem.desc) }
						}
					}
				}
				Component.onCompleted: mainItem.isScreenSharingMenu = true
				Component.onDestruction: mainItem.isScreenSharingMenu = false
			}
		}
	}
}
