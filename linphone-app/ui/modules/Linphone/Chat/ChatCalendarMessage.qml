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
	property int fitHeight: active && item ? item.fitHeight : 0
	property int fitWidth: active && item ? availableWidth/2  + ChatCalendarMessageStyle.widthMargin*2 : 0
	property bool containsMouse: false
	property int gotoButtonMode: -1	//-1: hide, 0:goto, 1:MoreInfo
	property bool isExpanded : false
	
	property bool isCancelled: conferenceInfoModel && conferenceInfoModel.state == LinphoneEnums.ConferenceInfoStateCancelled
	
	signal expandToggle()
	signal conferenceUriCopied()
	signal conferenceRemoved()
	
	width: parent.width
	height: parent.height
	
	property font customFont : SettingsModel.textMessageFont
	active: mainItem.conferenceInfoModel
	
	sourceComponent: MouseArea{
		id: loadedItem
		property int fitHeight: layout.fitHeight + ChatCalendarMessageStyle.topMargin+ChatCalendarMessageStyle.bottomMargin
		property int fitWidth: layout.fitWidth
		
		anchors.fill: parent
		anchors.leftMargin: ChatCalendarMessageStyle.widthMargin
		anchors.rightMargin: ChatCalendarMessageStyle.widthMargin
		anchors.topMargin: ChatCalendarMessageStyle.topMargin
		anchors.bottomMargin: ChatCalendarMessageStyle.bottomMargin
		
		clip: false
		
		hoverEnabled: true
		onClicked: mainItem.expandToggle()
		onHoveredChanged: mainItem.containsMouse = loadedItem.containsMouse		
		
		ColumnLayout{
			id: layout
			// Fix for binding loops
			property int participantsFitHeight: 0
			property int expandedFitHeight: 0
			function updateFitHeight(){
				participantsFitHeight = participantsRow.implicitHeight
				expandedFitHeight = (expandedDescription.visible? expandedDescription.implicitHeight : 0)
			}
			
			property int fitHeight: dateRow.implicitHeight + statusLabel.implicitHeight + title.implicitHeight + participantsFitHeight + expandedFitHeight
			property int fitWidth: Layout.minimumWidth
			anchors.fill: parent
			spacing: 0
			RowLayout {
				id: dateRow
				Layout.fillWidth: true
				//Layout.preferredWidth: parent.width	// Need this because fillWidth is not enough...
				Layout.preferredHeight: ChatCalendarMessageStyle.lineHeight
				Layout.alignment: Qt.AlignTop
				Layout.topMargin: 5
				spacing: 10
				RowLayout {
					id: scheduleRow
					Layout.fillWidth: true
					Layout.preferredHeight: ChatCalendarMessageStyle.lineHeight
					Layout.leftMargin: 5
					spacing: ChatCalendarMessageStyle.schedule.spacing
					Item{
						Layout.preferredHeight: ChatCalendarMessageStyle.lineHeight
						Layout.preferredWidth: ChatCalendarMessageStyle.schedule.iconSize
						clip: false
						Icon{
							anchors.centerIn: parent
							icon: ChatCalendarMessageStyle.schedule.icon
							iconSize: ChatCalendarMessageStyle.schedule.iconSize
							overwriteColor: ChatCalendarMessageStyle.schedule.colorModel.color
						}
					}
					
					Text {
						id: conferenceTime
						Layout.fillWidth: true
						Layout.preferredHeight: ChatCalendarMessageStyle.lineHeight
						Layout.minimumWidth: implicitWidth
						
						verticalAlignment: Qt.AlignVCenter
						color: ChatCalendarMessageStyle.schedule.colorModel.color
						elide: Text.ElideRight
						font.pointSize: ChatCalendarMessageStyle.schedule.pointSize
// Reminder: QML use locale time (not system). Use UTC from C++ => convert it into QML => pass QML => convert it into UTC and apply our timezone.
						text: UtilsCpp.toTimeString(Utils.fromUTC(mainItem.conferenceInfoModel.dateTimeUtc), 'hh:mm')
								+ (mainItem.conferenceInfoModel.duration > 0 ? ' (' +Utils.formatDuration(mainItem.conferenceInfoModel.duration * 60) + ')'
																			: '')																			
					}
				}
				Text{
					Layout.fillWidth: true
					Layout.preferredHeight: ChatCalendarMessageStyle.lineHeight
					Layout.rightMargin: 15
					horizontalAlignment: Qt.AlignRight
					verticalAlignment: Qt.AlignVCenter
					color: ChatCalendarMessageStyle.schedule.colorModel.color
					elide: Text.ElideRight
					font.pointSize: ChatCalendarMessageStyle.schedule.pointSize
					//: 'Organizer' : Label Title for the organizer.
					text: qsTr('icsOrganizer') +' : ' +UtilsCpp.getDisplayName(mainItem.conferenceInfoModel.organizer)
				}
			}
			
			Text{
				id: statusLabel
				Layout.fillWidth: true
				Layout.preferredHeight: visible ? ChatCalendarMessageStyle.lineHeight : 0
				Layout.alignment: Qt.AlignTop
				Layout.leftMargin: 10
				
				visible: mainItem.isCancelled
				
				elide: Text.ElideRight
				color: ChatCalendarMessageStyle.type.cancelledColor.color
				font.pointSize: ChatCalendarMessageStyle.type.pointSize
				font.weight: Font.Bold
				//: 'Meeting has been cancelled' : ICS Title for cancelled meetings
				text:qsTr('icsCancelledMeetingInvite')
			}
			
			Text{
				id: title
				Layout.fillWidth: true
				Layout.preferredHeight: ChatCalendarMessageStyle.lineHeight
				Layout.alignment: Qt.AlignTop
				Layout.leftMargin: 10
				
				elide: Text.ElideRight
				color: ChatCalendarMessageStyle.subject.colorModel.color
				font.pointSize: ChatCalendarMessageStyle.subject.pointSize
				font.weight: Font.Bold
				text: mainItem.conferenceInfoModel.subject
			}
			RowLayout {
				id: participantsRow
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.minimumHeight: 4 + (mainItem.isExpanded ? expandedParticipantsList.minimumHeight : ChatCalendarMessageStyle.lineHeight)
				Layout.alignment: Qt.AlignTop
				Layout.leftMargin: 5
				Layout.rightMargin: 10
				
				spacing: ChatCalendarMessageStyle.participants.spacing
				property int participantLineHeight: participantsList.implicitHeight
				// Fix for binding loops
				onImplicitHeightChanged: Qt.callLater( layout.updateFitHeight)
				
				Item{
					Layout.preferredHeight: parent.participantLineHeight
					Layout.preferredWidth: ChatCalendarMessageStyle.participants.iconSize
					Layout.alignment: Qt.AlignTop
					
					visible: mainItem.conferenceInfoModel.participantCount > 0
					clip: false
					Icon{
						anchors.top: parent.top
						anchors.horizontalCenter: parent.horizontalCenter
						icon: ChatCalendarMessageStyle.participants.icon
						iconSize: ChatCalendarMessageStyle.participants.iconSize
						overwriteColor: ChatCalendarMessageStyle.participants.colorModel.color
					}
				}
				
				Text {
					id: participantsList
					Layout.fillWidth: true
					Layout.preferredHeight: parent.participantLineHeight
					Layout.topMargin: 4
					Layout.alignment: Qt.AlignTop
					visible: !mainItem.isExpanded
					color: ChatCalendarMessageStyle.participants.colorModel.color
					elide: Text.ElideRight
					font.pointSize: ChatCalendarMessageStyle.participants.pointSize
					text: mainItem.conferenceInfoModel.displayNamesToString
				}
				ScrollableListView{
					id: expandedParticipantsList
					property int minimumHeight: Math.min( count * parent.participantLineHeight, layout.height/(descriptionTitle.visible?3:2))
					Layout.fillWidth: true
					Layout.topMargin: 4
					Layout.minimumHeight: minimumHeight
					Layout.alignment: Qt.AlignTop
					spacing: 0
					visible: mainItem.isExpanded
					onVisibleChanged: visible ? model= mainItem.conferenceInfoModel.getAllParticipants() : model = []
					Connections{
						target: mainItem.conferenceInfoModel
						onParticipantsChanged: if(expandedParticipantsList.visible) expandedParticipantsList.model = mainItem.conferenceInfoModel.getAllParticipants()
					}
					
					delegate: Row{
						spacing: 5
						width: expandedParticipantsList.contentWidth
						height: participantsRow.participantLineHeight
						Text{
							id: displayName
							height: participantsRow.participantLineHeight
							text: modelData.displayName
							color: ChatCalendarMessageStyle.participants.colorModel.color
							font.pointSize: ChatCalendarMessageStyle.participants.pointSize
							elide: Text.ElideRight
						}
						Text{
							height: participantsRow.participantLineHeight
							width: expandedParticipantsList.contentWidth - displayName.width - parent.spacing	// parent.width is not enough. Force width
							text: '('+modelData.address+')'
							color: ChatCalendarMessageStyle.participants.colorModel.color
							font.pointSize: ChatCalendarMessageStyle.participants.pointSize
							elide: Text.ElideRight
						}
					}
				}
				Item{
					Layout.preferredWidth: expandButton.iconSize
					Layout.preferredHeight: participantsRow.participantLineHeight
					Layout.alignment: Qt.AlignTop | Qt.AlignRight
					
					ActionButton{
						id: expandButton
						visible: mainItem.gotoButtonMode >= 0
						anchors.centerIn: parent
						anchors.verticalCenter: parent.verticalCenter
						isCustom: true
						colorSet: mainItem.gotoButtonMode == 0 ? ChatCalendarMessageStyle.gotoButton : ChatCalendarMessageStyle.infoButton
						iconSize: participantsRow.participantLineHeight
						backgroundRadius: width/2
						toggled: mainItem.isExpanded
						onClicked: mainItem.expandToggle()
					}
				}
			}
			ColumnLayout{
				id: expandedDescription
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.alignment: Qt.AlignTop
				Layout.topMargin: 5
				visible: mainItem.isExpanded
				spacing: 0
				// Fix for binding loops
				onVisibleChanged: Qt.callLater( layout.updateFitHeight)
				onImplicitHeightChanged: Qt.callLater( layout.updateFitHeight)
				Text{
					id: descriptionTitle
					Layout.fillWidth: true
					Layout.leftMargin: 10
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
					//Layout.fillHeight: true
					Layout.preferredHeight: visible ? implicitHeight : 0
					Layout.leftMargin: 10
					Layout.rightMargin: 10
					padding: 0
					color: 'transparent'
					readOnly: true
					textColor: ChatCalendarMessageStyle.description.colorModel.color
					font.pointSize: ChatCalendarMessageStyle.description.pointSize
					border.width: 0
					visible: description.text != ''
					text: mainItem.conferenceInfoModel.description
				}
				Text{
					id: linkTitle
					Layout.fillWidth: true
					Layout.leftMargin: 10
					Layout.topMargin: 5
					color: ChatCalendarMessageStyle.subject.colorModel.color
					font.pointSize: ChatCalendarMessageStyle.subject.pointSize
					font.weight: Font.Bold
					visible: !mainItem.isCancelled
					
					//: 'Meeting address' : Title for the meeting address.
					text: qsTr('icsconferenceAddressTitle')
				}
				RowLayout{
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.leftMargin: 10
					Layout.rightMargin: 10
					spacing: 10
					visible: !mainItem.isCancelled
					TextField{
						id: uriField
						readOnly: true
						Layout.fillWidth: true
						Layout.preferredHeight: ChatCalendarMessageStyle.copyLinkButton.iconSize
						textFieldStyle: TextFieldStyle.flatInverse
						text: mainItem.conferenceInfoModel.uri
						
					}
					ActionButton{
						isCustom: true
						colorSet: ChatCalendarMessageStyle.copyLinkButton
						backgroundRadius: width/2
						onClicked: {
								Clipboard.text = uriField.text
								mainItem.conferenceUriCopied()
							}
					}
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
					TextButtonC{
						addHeight: 20
						//: 'Join' : Action button to join the meeting.
						text: qsTr('icsJoinButton').toUpperCase()
						onClicked: CallsListModel.prepareConferenceCall(mainItem.conferenceInfoModel)
						visible: !mainItem.isCancelled
					}
					ActionButton{
						id: editButton
						isCustom: true
						colorSet: ChatCalendarMessageStyle.editButton
						backgroundRadius: width/2
						visible: UtilsCpp.isMe(mainItem.conferenceInfoModel.organizer) 
								&& !mainItem.conferenceInfoModel.isEnded
								&& !mainItem.isCancelled
						onClicked: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Utils.buildAppDialogUri('NewConference')
													   ,{conferenceInfoModel: mainItem.conferenceInfoModel, forceSchedule: true})
						}
					}
					ActionButton{
						property bool isCancellable: editButton.visible
						
						isCustom: true
						colorSet: ChatCalendarMessageStyle.deleteButton
						backgroundRadius: width/2
						onClicked: {
							window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
								//: 'Do you really want do cancel this meeting?' : Warning message to confirm the cancellation of a meeting.
								descriptionText: isCancellable
									? qsTr('cancelConferenceInfo')
								//: 'Do you really want do delete this meeting?' : Warning message to confirm the deletion of a meeting.
									: qsTr('deleteConferenceInfo')
								,
							  }, function (status) {
								if (status) {
									if( isCancellable)
										mainItem.conferenceInfoModel.cancelConference()
									else
										mainItem.conferenceInfoModel.deleteConferenceInfo()
								}
							  })
						}
					}
					Item{
						Layout.fillWidth: mainItem.isCancelled
					}
				}
			}
		}
	}
	Connections{
		target: conferenceInfoModel
		onRemoved: if(byUser) mainItem.conferenceRemoved()
	}
}

