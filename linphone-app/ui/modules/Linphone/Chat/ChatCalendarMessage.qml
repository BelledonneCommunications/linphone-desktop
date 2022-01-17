import QtQuick 2.7
import QtQuick.Layouts 1.3

import Clipboard 1.0
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

// =============================================================================

Loader{
	id: mainItem
	property ContentModel contentModel
	property ConferenceInfoModel conferenceInfoModel: contentModel && active ? contentModel.conferenceInfoModel : null
	property int maxWidth : parent.width
	property int fitHeight: active && item ? item.fitHeight + ChatCalendarMessageStyle.heightMargin*2 : 0
	property int fitWidth: active && item ? Math.max(item.fitWidth, maxWidth/2)  + ChatCalendarMessageStyle.widthMargin*2 : 0
	width: parent.width
	height: fitHeight
	
	property font customFont : SettingsModel.textMessageFont
	active: (mainItem.contentModel && mainItem.contentModel.isIcalendar()) || (!mainItem.contentModel && mainItem.conferenceInfoModel)
	
	sourceComponent: MouseArea{
		id: loadedItem
		property int fitHeight: layout.fitHeight
		property int fitWidth: layout.fitWidth
		
		anchors.fill: parent
		anchors.leftMargin: ChatCalendarMessageStyle.widthMargin
		anchors.rightMargin: ChatCalendarMessageStyle.widthMargin
		anchors.topMargin: ChatCalendarMessageStyle.heightMargin
		anchors.bottomMargin: ChatCalendarMessageStyle.heightMargin
		
		clip: false
		
		cursorShape: Qt.ArrowCursor
		hoverEnabled: true
		onClicked: CallsListModel.launchVideoCall(mainItem.conferenceInfoModel.uri, '', 0)
		
		ColumnLayout{
			id: layout
			property int fitHeight: Layout.minimumHeight
			property int fitWidth: Layout.minimumWidth
			anchors.fill: parent
			spacing: 0
			RowLayout {
				Layout.fillWidth: true
				Layout.preferredWidth: parent.width	// Need this because fillWidth is not enough...
				Layout.preferredHeight: ChatCalendarMessageStyle.schedule.iconSize
				spacing: 10
				RowLayout {
					id: scheduleRow
					Layout.fillWidth: true
					Layout.preferredHeight: ChatCalendarMessageStyle.schedule.iconSize
					Layout.leftMargin: 5
					spacing: ChatCalendarMessageStyle.schedule.spacing
					
					Icon{
						icon: ChatCalendarMessageStyle.schedule.icon
						iconSize: ChatCalendarMessageStyle.schedule.iconSize
						overwriteColor: ChatCalendarMessageStyle.schedule.color
					}
					
					Text {
						id: conferenceTime
						Layout.fillWidth: true
						Layout.minimumWidth: implicitWidth
						verticalAlignment: Qt.AlignVCenter
						color: ChatCalendarMessageStyle.schedule.color
						elide: Text.ElideRight
						font.pointSize: ChatCalendarMessageStyle.schedule.pointSize
						text: Qt.formatDateTime(mainItem.conferenceInfoModel.dateTime, 'hh:mm')
							+' - ' +Qt.formatDateTime(mainItem.conferenceInfoModel.endDateTime, 'hh:mm')
					}
				}
				Item{
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
				Text{
					Layout.fillHeight: true
					Layout.minimumWidth: implicitWidth
					Layout.preferredWidth: implicitWidth
					Layout.rightMargin: 10
					verticalAlignment: Qt.AlignVCenter
					color: ChatCalendarMessageStyle.schedule.color
					elide: Text.ElideRight
					font.pointSize: ChatCalendarMessageStyle.schedule.pointSize
					text: 'Organisateur : ' +UtilsCpp.getDisplayName(mainItem.conferenceInfoModel.organizer)
				}
			}
			Text{
				id: title
				Layout.fillWidth: true
				Layout.minimumWidth: implicitWidth
				Layout.topMargin: 10
				Layout.leftMargin: 10
				Layout.alignment: Qt.AlignRight
				color: ChatCalendarMessageStyle.subject.color
				font.pointSize: ChatCalendarMessageStyle.subject.pointSize
				font.weight: Font.Bold
				text: mainItem.conferenceInfoModel.subject
			}
			RowLayout {
				id: participantsRow
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.leftMargin: 5
				
				spacing: ChatCalendarMessageStyle.participants.spacing
				
				Icon{
					icon: ChatCalendarMessageStyle.participants.icon
					iconSize: ChatCalendarMessageStyle.participants.iconSize
					overwriteColor: ChatCalendarMessageStyle.participants.color
				}
				
				Text {
					id: participantsList
					Layout.fillWidth: true
					Layout.minimumWidth: implicitWidth
					color: ChatCalendarMessageStyle.participants.color
					elide: Text.ElideRight
					font.pointSize: ChatCalendarMessageStyle.participants.pointSize
					text: mainItem.conferenceInfoModel.displayNamesToString
				}
			}
		}
	}
}

