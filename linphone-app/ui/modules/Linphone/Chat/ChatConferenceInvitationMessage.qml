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
	property int availableWidth : parent.width
	property int fitHeight: active && item ? item.fitHeight : 0 // + (isExpanded? 200 : 0): 0
	property int fitWidth: active && item ? Math.min(availableWidth > 0 ? availableWidth : 9999999, item.fitWidth  + ChatCalendarMessageStyle.widthMargin*2) : 0
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
		
		clip: false
		
		hoverEnabled: true
		onClicked: CallsListModel.prepareConferenceCall(mainItem.conferenceInfoModel)
		onHoveredChanged: mainItem.containsMouse = loadedItem.containsMouse
		Rectangle{
			anchors.fill: parent
			color: ChatCalendarMessageStyle.backgroundColor.normal.color
			radius: 5
		}
		
		ColumnLayout{
			id: layout
			// Fix for binding loops
			property int minHeight: layout.implicitHeight
			function updateFitHeight(){
				fitHeight = minHeight + (description.visible? description.implicitHeight : 0)
			}
			
			onMinHeightChanged: Qt.callLater( layout.updateFitHeight)
			property int fitHeight: 0
			property int fitWidth: Math.max(titleItem.implicitWidth, Math.max(shareButton.width + joinButton.width, description.fitWidth))
			anchors.fill: parent
			spacing: 0
			Text{
				id: titleItem
				Layout.fillWidth: true
				Layout.topMargin: 5
				Layout.leftMargin: 5
				Layout.alignment: Qt.AlignRight
				elide: Text.ElideRight
				color: mainItem.conferenceInfoModel.state == LinphoneEnums.ConferenceInfoStateUpdated 
										? ChatCalendarMessageStyle.type.updatedColor.color
										: mainItem.conferenceInfoModel.state == LinphoneEnums.ConferenceInfoStateCancelled
											? ChatCalendarMessageStyle.type.cancelledColor.color
											: ChatCalendarMessageStyle.type.colorModel.color
				
				font.pointSize: ChatCalendarMessageStyle.type.pointSize
				font.weight: Font.Bold
				text:  (mainItem.conferenceInfoModel.state == LinphoneEnums.ConferenceInfoStateUpdated
				//: 'Meeting has been updated' : ICS title for an updated invitation.
						? qsTr('icsUpdatedMeetingInvite')
						:  mainItem.conferenceInfoModel.state == LinphoneEnums.ConferenceInfoStateCancelled
				//: 'Meeting has been cancelled' : ICS title for a cancelled invitation.
							? qsTr('icsCancelledMeetingInvite')
				//: 'Meeting invite' : ICS title that is an invitation.
							: qsTr('icsMeetingInvite')
							) +': '// + UtilsCpp.getDisplayName(mainItem.conferenceInfoModel.organizer)
			}
			Text{
				id: title
				Layout.fillWidth: true
				Layout.leftMargin: 5
				Layout.alignment: Qt.AlignRight
				elide: Text.ElideRight
				color: ChatCalendarMessageStyle.subject.colorModel.color
				font.pointSize: ChatCalendarMessageStyle.subject.pointSize
				text: mainItem.conferenceInfoModel.subject
			}
			RowLayout {
				id: participantsRow
				property int participantCount: mainItem.conferenceInfoModel.allParticipantCount
				Layout.fillWidth: true
				Layout.preferredHeight: ChatCalendarMessageStyle.participants.iconSize
				Layout.leftMargin: 5
				Layout.rightMargin: 15
				
				spacing: ChatCalendarMessageStyle.participants.spacing				
				visible: participantsRow.participantCount > 0 && mainItem.conferenceInfoModel.state != LinphoneEnums.ConferenceInfoStateCancelled
				
				Icon{
					icon: ChatCalendarMessageStyle.participants.icon
					iconSize: ChatCalendarMessageStyle.participants.iconSize
					overwriteColor: ChatCalendarMessageStyle.participants.colorModel.color
				}
				
				Text {
					id: participantsList
					Layout.fillWidth: true
					color: ChatCalendarMessageStyle.participants.colorModel.color
					elide: Text.ElideRight
					font.pointSize: ChatCalendarMessageStyle.participants.pointSize
					//: '%1 participant' : number(=%1) of participant.
					text:  qsTr('icsParticipants', '', participantsRow.participantCount).arg(participantsRow.participantCount)
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
						overwriteColor: ChatCalendarMessageStyle.calendar.colorModel.color
					}
					
					Text {
						id: conferenceDate
						Layout.fillWidth: true
						Layout.minimumWidth: implicitWidth
						verticalAlignment: Qt.AlignVCenter
						color: ChatCalendarMessageStyle.schedule.colorModel.color
						elide: Text.ElideRight
						font.pointSize: Units.dp * 8
						text: UtilsCpp.toDateString(Utils.fromUTC(mainItem.conferenceInfoModel.dateTimeUtc), 'yyyy/MM/dd')
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
						overwriteColor: ChatCalendarMessageStyle.schedule.colorModel.color
					}
					
					Text {
						id: conferenceTime
						Layout.fillWidth: true
						Layout.minimumWidth: implicitWidth
						verticalAlignment: Qt.AlignVCenter
						color: ChatCalendarMessageStyle.schedule.colorModel.color
						elide: Text.ElideRight
						font.pointSize: Units.dp * 8
// Reminder: QML use locale time (not system). Use UTC from C++ => convert it into QML => pass QML => convert it into UTC and apply our timezone.
						text: UtilsCpp.toTimeString( Utils.fromUTC(mainItem.conferenceInfoModel.dateTimeUtc), 'hh:mm')
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
					onVisibleChanged: visible ? model= mainItem.conferenceInfoModel.getAllParticipants() : model = []
					Connections{
						target: mainItem.conferenceInfoModel
						onParticipantsChanged: if(expandedParticipantsList.visible) expandedParticipantsList.model = mainItem.conferenceInfoModel.getAllParticipants()
					}
					
					delegate: Row{
						spacing: 5
						width: expandedParticipantsList.width
						height: ChatCalendarMessageStyle.lineHeight
						Text{text: modelData.displayName
							color: ChatCalendarMessageStyle.description.colorModel.color
							font.pointSize: ChatCalendarMessageStyle.description.pointSize
							elide: Text.ElideRight
							wrapMode: TextEdit.WordWrap
						}
						Text{text: '('+modelData.address+')'
							color: ChatCalendarMessageStyle.description.colorModel.color
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
				color: ChatCalendarMessageStyle.subject.colorModel.color
				font.pointSize: ChatCalendarMessageStyle.subject.pointSize
				font.weight: Font.Bold
				//: 'Description' : Title for the meeting description.
				text: qsTr('icsDescription')
				visible: description.text != ''
			}
			TextAreaField{
				id: description
				Layout.fillWidth: true
				Layout.preferredHeight: visible ? implicitHeight : 0
				Layout.leftMargin: 5
				padding: 0
				color: 'transparent'
				readOnly: true
				textColor: ChatCalendarMessageStyle.description.colorModel.color
				font.pointSize: ChatCalendarMessageStyle.description.pointSize
				border.width: 0
				visible: description.text != ''
				
				text: mainItem.conferenceInfoModel.description
				
				onImplicitHeightChanged: Qt.callLater( layout.updateFitHeight)
				onVisibleChanged: Qt.callLater( layout.updateFitHeight)
			}
			RowLayout{
				Layout.fillWidth: true
				Layout.topMargin: 10
				Layout.bottomMargin: 5
				Layout.rightMargin: 10
				spacing: 10
				Item{
					Layout.fillWidth: true
				}
				ActionButton{
					id: shareButton
					visible: joinButton.visible
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
					addHeight: 20
					visible: mainItem.conferenceInfoModel.state != LinphoneEnums.ConferenceInfoStateCancelled
					//: 'Join' : Action button to join the meeting.
					text: qsTr('icsJoinButton').toUpperCase()
					onClicked: CallsListModel.prepareConferenceCall(mainItem.conferenceInfoModel)
				}
			}
		}
	}
}

