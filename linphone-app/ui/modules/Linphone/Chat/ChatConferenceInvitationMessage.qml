import QtQuick 2.7
import QtQuick.Layouts 1.3

import Clipboard 1.0
import App 1.0
import Common 1.0
import Linphone 1.0

import Common.Styles 1.0
import Linphone.Styles 1.0
import TextToSpeech 1.0
import Utils 1.0
import Units 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import ColorsList 1.0

import 'Message.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Loader{
	id: mainItem
	property ContentModel contentModel
	property ConferenceInfoModel conferenceInfoModel: contentModel ? contentModel.conferenceInfoModel : null
	property int maxWidth : parent.width
	property int fitHeight: active && item ? item.fitHeight + (isExpanded? 200 : 0): 0
	property int fitWidth: active && item ? Math.min(maxWidth, item.fitWidth  + ChatCalendarMessageStyle.widthMargin*2) : 0
	property bool containsMouse: false
	property int gotoButtonMode: -1	//-1: hide, 0:goto, 1:MoreInfo
	property bool isExpanded : false
	
	signal expandToggle()
	signal conferenceIcsCopied()
	
	width: parent.width
	height: parent.height
	
	property font customFont : SettingsModel.textMessageFont
	active: mainItem.conferenceInfoModel
	
	sourceComponent: MouseArea{
		id: loadedItem
		property int fitHeight: layout.fitHeight + ChatCalendarMessageStyle.topMargin+ChatCalendarMessageStyle.bottomMargin
		property int fitWidth: layout.fitWidth + ChatCalendarMessageStyle.leftMargin+ChatCalendarMessageStyle.rightMargin
		
		anchors.fill: parent
		anchors.leftMargin: ChatCalendarMessageStyle.widthMargin
		anchors.rightMargin: ChatCalendarMessageStyle.widthMargin
		anchors.topMargin: ChatCalendarMessageStyle.topMargin
		anchors.bottomMargin: ChatCalendarMessageStyle.bottomMargin
		
		clip: false
		
		hoverEnabled: true
		onClicked: CallsListModel.prepareConferenceCall(mainItem.conferenceInfoModel)
		onHoveredChanged: mainItem.containsMouse = loadedItem.containsMouse		
		
		ColumnLayout{
			id: layout
			property int fitHeight: Layout.minimumHeight + (description.visible?description.implicitHeight + 5: 5)
			property int fitWidth: Math.max(shareButton.width + joinButton.width, description.fitWidth)
			anchors.fill: parent
			spacing: 0
			Text{
				Layout.fillWidth: true
				Layout.topMargin: 5
				Layout.leftMargin: 5
				Layout.alignment: Qt.AlignRight
				elide: Text.ElideRight
				color: ChatCalendarMessageStyle.type.color
				font.pointSize: ChatCalendarMessageStyle.type.pointSize
				font.weight: Font.Bold
				//: 'Meeting invite' : ICS title that is an invitation.
				text: qsTr('icsMeetingInvite') +': '// + UtilsCpp.getDisplayName(mainItem.conferenceInfoModel.organizer)
			}
			Text{
				id: title
				Layout.fillWidth: true
				Layout.leftMargin: 5
				Layout.alignment: Qt.AlignRight
				elide: Text.ElideRight
				color: ChatCalendarMessageStyle.subject.color
				font.pointSize: ChatCalendarMessageStyle.subject.pointSize
				font.weight: Font.Bold
				text: mainItem.conferenceInfoModel.subject
			}
			RowLayout {
				id: participantsRow
				Layout.fillWidth: true
				Layout.preferredHeight: ChatCalendarMessageStyle.participants.iconSize
				Layout.leftMargin: 5
				Layout.rightMargin: 15
				
				spacing: ChatCalendarMessageStyle.participants.spacing
				
				Icon{
					icon: ChatCalendarMessageStyle.participants.icon
					iconSize: ChatCalendarMessageStyle.participants.iconSize
					overwriteColor: ChatCalendarMessageStyle.participants.color
				}
				
				Text {
					id: participantsList
					property int participantCount: mainItem.conferenceInfoModel.getParticipantCount()
					Layout.fillWidth: true
					color: ChatCalendarMessageStyle.participants.color
					elide: Text.ElideRight
					font.pointSize: ChatCalendarMessageStyle.participants.pointSize
					//: '%1 participant' : number(=%1) of participant.
					text:  qsTr('icsParticipants', '', participantCount).arg(participantCount)
				}
			}
			ColumnLayout{
				Layout.fillWidth: true
				Layout.leftMargin: 5
				Layout.rightMargin: 15
				spacing: 0
				RowLayout {
					id: dateRow
					Layout.fillWidth: true
					Layout.preferredHeight: conferenceDate.implicitHeight
					spacing: ChatCalendarMessageStyle.calendar.spacing
					
					Icon{
						icon: ChatCalendarMessageStyle.calendar.icon
						iconSize: ChatCalendarMessageStyle.calendar.iconSize-2
						overwriteColor: ChatCalendarMessageStyle.calendar.color
					}
					
					Text {
						id: conferenceDate
						Layout.fillWidth: true
						Layout.minimumWidth: implicitWidth
						verticalAlignment: Qt.AlignVCenter
						color: ChatCalendarMessageStyle.schedule.color
						elide: Text.ElideRight
						font.pointSize: Units.dp * 8
						text: Qt.formatDate(mainItem.conferenceInfoModel.dateTimeUtc, 'yyyy/MM/dd')
					}
				}
				RowLayout {
					id: conferenceTimeRow
					Layout.fillWidth: true
					Layout.preferredHeight: conferenceTime.implicitHeight
					
					spacing: ChatCalendarMessageStyle.schedule.spacing
					
					Icon{
						icon: ChatCalendarMessageStyle.schedule.icon
						iconSize: ChatCalendarMessageStyle.schedule.iconSize-2
						overwriteColor: ChatCalendarMessageStyle.schedule.color
					}
					
					Text {
						id: conferenceTime
						Layout.fillWidth: true
						Layout.minimumWidth: implicitWidth
						verticalAlignment: Qt.AlignVCenter
						color: ChatCalendarMessageStyle.schedule.color
						elide: Text.ElideRight
						font.pointSize: Units.dp * 8
						text: Qt.formatDateTime(mainItem.conferenceInfoModel.dateTimeUtc, 'hh:mm')
							  + (mainItem.conferenceInfoModel.duration > 0 ? ' ('+Utils.formatDuration(mainItem.conferenceInfoModel.duration * 60) + ')'
																		   : '')
					}
				}
			}
			ColumnLayout{
				id: expandedDescription
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.topMargin: 5
				visible: mainItem.isExpanded
				spacing: 0
				ScrollableListView{
					id: expandedParticipantsList
					Layout.fillWidth: true
					Layout.minimumHeight: Math.min( count * ChatCalendarMessageStyle.lineHeight, parent.height/(descriptionTitle.visible?3:2))
					Layout.leftMargin: 10
					spacing: 0
					visible: mainItem.isExpanded
					onVisibleChanged: model= mainItem.conferenceInfoModel.getParticipants()
					
					delegate: Row{
						spacing: 5
						width: expandedParticipantsList.width
						height: ChatCalendarMessageStyle.lineHeight
						Text{text: modelData.displayName
							color: ChatCalendarMessageStyle.description.color
							font.pointSize: ChatCalendarMessageStyle.description.pointSize
							elide: Text.ElideRight
							wrapMode: TextEdit.WordWrap
						}
						Text{text: '('+modelData.address+')'
							color: ChatCalendarMessageStyle.description.color
							font.pointSize: ChatCalendarMessageStyle.description.pointSize
							elide: Text.ElideRight
							wrapMode: TextEdit.WordWrap
						}
					}
				}
			}
			Text{
				id: descriptionTitle
				Layout.fillWidth: true
				Layout.leftMargin: 5
				Layout.topMargin: 5
				color: ChatCalendarMessageStyle.subject.color
				font.pointSize: ChatCalendarMessageStyle.subject.pointSize
				font.weight: Font.Bold
				//: 'Description' : Title for the conference description.
				text: qsTr('icsDescription')
				visible: description.text != ''
			}
			TextAreaField{
				id: description
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.leftMargin: 5
				padding: 0
				color: 'transparent'
				readOnly: true
				textColor: ChatCalendarMessageStyle.description.color
				font.pointSize: ChatCalendarMessageStyle.description.pointSize
				border.width: 0
				visible: description.text != ''
				
				text: mainItem.conferenceInfoModel.description
			}
			Item{
				Layout.fillHeight: true
				Layout.fillWidth: true
			}
			RowLayout{
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.topMargin: ChatCalendarMessageStyle.bottomMargin
				Layout.leftMargin: 5
				Layout.rightMargin: 5
				spacing: 10
				Item{
					Layout.fillHeight: true
					Layout.fillWidth: true
				}
				ActionButton{
					id: shareButton
					iconSize: joinButton.height/2
					isCustom: true
					colorSet: ChatCalendarMessageStyle.shareButton
					backgroundRadius: width/2
					onClicked: {
						Clipboard.text = mainItem.conferenceInfoModel.getIcalendarString()
						mainItem.conferenceIcsCopied()
					}
				}
				TextButtonC{
					id: joinButton
					//: 'Join' : Action button to join the conference.
					text: qsTr('icsJoinButton').toUpperCase()
					onClicked: CallsListModel.prepareConferenceCall(mainItem.conferenceInfoModel)
				}
			}
		}
	}
}

