import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.12
import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import LinphoneEnums 1.0

import UtilsCpp 1.0

import App.Styles 1.0


// Temp
import 'Incall.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Rectangle{
	id: mainItem
	property CallModel callModel
	signal close()
	
	height: 500
	width: 400
	color: "white"
	radius: VideoConferenceMenuStyle.radius
	ButtonGroup{id: modeGroup}
	ColumnLayout{
		anchors.fill: parent
// HEADER
		Borders{
			Layout.fillWidth: true
			Layout.preferredHeight: Math.max(VideoConferenceMenuStyle.header.height, title.implicitHeight+20)
			bottomColor: VideoConferenceMenuStyle.list.border.color
			bottomWidth: VideoConferenceMenuStyle.list.border.width
			RowLayout{
				anchors.fill: parent
				ActionButton{
					//Layout.minimumHeight: VideoConferenceMenuStyle.buttons.back.iconSize
					//Layout.minimumWidth: VideoConferenceMenuStyle.buttons.back.iconSize
					backgroundRadius: width/2
					isCustom: true
					colorSet: VideoConferenceMenuStyle.buttons.back
					onClicked: contentsStack.pop()
					visible: contentsStack.nViews > 1
				}
				Text{
					id: title
					text: 'Paramètres'
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
			onPopEnterChanged: if(nViews <= 1 ) title.text = 'Paramètres'
		}
		Component{
			id: settingsMenuComponent
			ColumnLayout{
				property string objectName: 'settingsMenu'
				Layout.fillHeight: true
				Layout.fillWidth: true
				Repeater{
					model: [
						{text: 'Régler les périphériques'
						, icon: VideoConferenceMenuStyle.settingsIcons.mediaIcon
						, nextPage:mediaMenu},

						{text: 'Modifier la mise en page'
						, icon: (mainItem.callModel.videoEnabled ?
										(mainItem.callModel.conferenceVideoLayout == LinphoneEnums.ConferenceLayoutGrid ? VideoConferenceMenuStyle.settingsIcons.gridIcon : VideoConferenceMenuStyle.settingsIcons.activeSpeakerIcon)
									: VideoConferenceMenuStyle.settingsIcons.audioOnlyIcon)
						, nextPage:layoutMenu}
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
		
								text: modelData.text
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
								title.text = modelData.text
								contentsStack.push(modelData.nextPage)
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
		Component{
			id: mediaMenu
			ColumnLayout{
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
					onExitStatus: contentsStack.pop()
				}
				Item{// Spacer
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
			}
		}
		Component{
			id: layoutMenu
			ColumnLayout{
				Layout.fillHeight: true
				Layout.fillWidth: true
				Repeater{
					model: [{text: 'Mode mosaïque', icon: VideoConferenceMenuStyle.modeIcons.gridIcon, value:LinphoneEnums.ConferenceLayoutGrid}
						, {text: 'Mode présentateur', icon: VideoConferenceMenuStyle.modeIcons.activeSpeakerIcon, value:LinphoneEnums.ConferenceLayoutActiveSpeaker}
						, {text: 'Mode audio', icon: VideoConferenceMenuStyle.modeIcons.audioOnlyIcon, value:2}
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
								onCheckedChanged: console.log(mainItem.callModel ? mainItem.callModel.videoEnabled +","+mainItem.callModel.conferenceVideoLayout  : '')
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
	}
}
