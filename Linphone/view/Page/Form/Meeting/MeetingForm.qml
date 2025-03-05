import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

FocusScope {
	id: mainItem
	property bool isCreation
	property ConferenceInfoGui conferenceInfoGui
	signal addParticipantsRequested()

	ColumnLayout {
		id: formLayout
        spacing: Math.round(16 * DefaultStyle.dp)
		anchors.fill: parent

		Component.onCompleted: {
			endHour.selectedDateTime = mainItem.conferenceInfoGui.core.endDateTime
			startHour.selectedDateTime = mainItem.conferenceInfoGui.core.dateTime
			startDate.calendar.selectedDate = mainItem.conferenceInfoGui.core.dateTime
		}

		RowLayout {
			visible: mainItem.isCreation && !SettingsCpp.disableBroadcastFeature
            Layout.topMargin: Math.round(20 * DefaultStyle.dp)
            Layout.bottomMargin: Math.round(20 * DefaultStyle.dp)
            spacing: Math.round(18 * DefaultStyle.dp)
			CheckableButton {
                Layout.preferredWidth: Math.round(151 * DefaultStyle.dp)
				icon.source: AppIcons.usersThree
                icon.width: Math.round(24 * DefaultStyle.dp)
                icon.height: Math.round(24 * DefaultStyle.dp)
				enabled: false
                //: "Réunion"
                text: qsTr("meeting_schedule_meeting_label")
				checked: true
				autoExclusive: true
				style: ButtonStyle.secondary
			}
			CheckableButton {
                Layout.preferredWidth: Math.round(151 * DefaultStyle.dp)
				enabled: false
				icon.source: AppIcons.slide
                icon.width: Math.round(24 * DefaultStyle.dp)
                icon.height: Math.round(24 * DefaultStyle.dp)
                //: "Webinar"
                text: qsTr("meeting_schedule_broadcast_label")
				autoExclusive: true
				style: ButtonStyle.secondary
			}
		}
		Section {
			visible: mainItem.isCreation
			spacing: formLayout.spacing
			content: RowLayout {
                spacing: Math.round(8 * DefaultStyle.dp)
				EffectImage {
					imageSource: AppIcons.usersThree
					colorizationColor: DefaultStyle.main2_600
                    Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
				}
				TextInput {
					id: confTitle
					Layout.fillWidth: true
                    //: "Ajouter un titre"
                    property string defaultText: qsTr("meeting_schedule_subject_hint")
					text: defaultText
					color: DefaultStyle.main2_600
					font {
                        pixelSize: Math.round(20 * DefaultStyle.dp)
                        weight: Typography.h3.weight
					}
					focus: true
					onActiveFocusChanged: if(activeFocus) {
						if (text == defaultText)
							clear()
						else selectAll()
					}
					onTextEdited: mainItem.conferenceInfoGui.core.subject = text
					KeyNavigation.down: startDate
				}
			}
		}
		Section {
			spacing: formLayout.spacing
			content: [
				RowLayout {
					EffectImage {
						imageSource: AppIcons.clock
						colorizationColor: DefaultStyle.main2_600
                        Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
					}
					CalendarComboBox {
						id: startDate
						background.visible: mainItem.isCreation
						indicator.visible: mainItem.isCreation
                        contentText.font.weight: Math.min(Math.round((isCreation ? 700 : 400) * DefaultStyle.dp), 1000)
						Layout.fillWidth: true
                        Layout.preferredHeight: Math.round(30 * DefaultStyle.dp)
						KeyNavigation.up: confTitle
						KeyNavigation.down: startHour
						onSelectedDateChanged: {
							if (!selectedDate || selectedDate == mainItem.conferenceInfoGui.core.dateTime) return
							mainItem.conferenceInfoGui.core.dateTime = UtilsCpp.createDateTime(selectedDate, startHour.selectedHour, startHour.selectedMin)
							mainItem.conferenceInfoGui.core.endDateTime = UtilsCpp.createDateTime(selectedDate, endHour.selectedHour, endHour.selectedMin)
							startHour.selectedDateTime = UtilsCpp.createDateTime(selectedDate, startHour.selectedHour, startHour.selectedMin)
							endHour.selectedDateTime = UtilsCpp.createDateTime(selectedDate, endHour.selectedHour, endHour.selectedMin)
						}
					}
				},
				RowLayout {
					Item {
                        Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
					}
					RowLayout {
						TimeComboBox {
							id: startHour
							// indicator.visible: mainItem.isCreation
                            Layout.preferredWidth: Math.round(94 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(30 * DefaultStyle.dp)
							background.visible: mainItem.isCreation
                            contentText.font.weight: Math.min(Math.round((isCreation ? 700 : 400) * DefaultStyle.dp), 1000)
							KeyNavigation.up: startDate
							KeyNavigation.down: timeZoneCbox
							KeyNavigation.left: endHour
							KeyNavigation.right: endHour
							onSelectedDateTimeChanged: {
								mainItem.conferenceInfoGui.core.dateTime = selectedDateTime
								endHour.minTime = selectedDateTime
								endHour.maxTime = UtilsCpp.createDateTime(selectedDateTime, 23, 59)
								if (mainItem.isCreation) {
									endHour.selectedDateTime = UtilsCpp.addSecs(selectedDateTime, 3600)
								}
							}
						}
						TimeComboBox {
							id: endHour
							// indicator.visible: mainItem.isCreation
                            Layout.preferredWidth: Math.round(94 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(30 * DefaultStyle.dp)
							background.visible: mainItem.isCreation
                            contentText.font.weight: Math.min(Math.round((isCreation ? 700 : 400) * DefaultStyle.dp), 1000)
							onSelectedDateTimeChanged: mainItem.conferenceInfoGui.core.endDateTime = selectedDateTime
							KeyNavigation.up: startDate
							KeyNavigation.down: timeZoneCbox
							KeyNavigation.left: startHour
							KeyNavigation.right: startHour
						}
						Item {
							Layout.fillWidth: true
						}
						Text {
							property int durationSec: UtilsCpp.secsTo(startHour.selectedTime, endHour.selectedTime)
							property int hour: durationSec/3600
							property int min: (durationSec - hour*3600)/60
							text: (hour > 0 ? hour + "h" : "") + (min > 0 ? min + "mn" : "")
							font {
                                pixelSize: Typography.p2l.pixelSize
                                weight: Typography.p2l.weight
							}
						}
					}
				},

				ComboBox {
					id: timeZoneCbox
					Layout.fillWidth: true
                    Layout.preferredHeight: Math.round(30 * DefaultStyle.dp)
					hoverEnabled: true
					oneLine: true
                    listView.implicitHeight: Math.round(250 * DefaultStyle.dp)
					constantImageSource: AppIcons.globe
                    weight: Typography.p2l.weight
					leftMargin: 0
					currentIndex: mainItem.conferenceInfoGui && model.count > 0 ? model.getIndex(mainItem.conferenceInfoGui.core.timeZoneModel) : -1
					background: Rectangle {
						visible: parent.hovered || parent.down
						anchors.fill: parent
						color: DefaultStyle.grey_100
					}
					model: TimeZoneProxy{
					}
					visible: model.count > 0
					onCurrentIndexChanged: {
						var modelIndex = timeZoneCbox.model.index(currentIndex, 0)
						mainItem.conferenceInfoGui.core.timeZoneModel = timeZoneCbox.model.data(modelIndex, Qt.DisplayRole + 1)
					}
				}
			]
			
		}
		Section {
			spacing: formLayout.spacing
			content: RowLayout {
                spacing: Math.round(8 * DefaultStyle.dp)
				EffectImage {
					imageSource: AppIcons.note
					colorizationColor: DefaultStyle.main2_600
                    Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
				}
				TextArea {
					id: descriptionEdit
					Layout.fillWidth: true
                    Layout.preferredWidth: Math.round(275 * DefaultStyle.dp)
                    leftPadding: Math.round(8 * DefaultStyle.dp)
                    rightPadding: Math.round(8 * DefaultStyle.dp)
					hoverEnabled: true
                    //: "Ajouter une description"
                    placeholderText: qsTr("meeting_schedule_description_hint")
					placeholderTextColor: DefaultStyle.main2_600
                    placeholderWeight: Typography.p2l.weight
					color: DefaultStyle.main2_600
					Component.onCompleted: text = conferenceInfoGui.core.description
					font {
                        pixelSize: Typography.p1.pixelSize
                        weight: Typography.p1.weight
					}
					onEditingFinished: mainItem.conferenceInfoGui.core.description = text
					Keys.onPressed: (event)=> {
						if (event.key == Qt.Key_Escape) {
							text = mainItem.conferenceInfoGui.core.description
							nextItemInFocusChain().forceActiveFocus()
							event.accepted = true;
						}
					}
					background: Rectangle {
						anchors.fill: parent
						color: descriptionEdit.hovered || descriptionEdit.activeFocus ? DefaultStyle.grey_100 : "transparent"
                        radius: Math.round(4 * DefaultStyle.dp)
					}
				}
			}
		}
		Section {
			spacing: formLayout.spacing
			content: [
				Button {
					id: addParticipantsButton
					Layout.fillWidth: true
                    Layout.preferredHeight: Math.round(30 * DefaultStyle.dp)
					background: Rectangle {
						anchors.fill: parent
						color: addParticipantsButton.hovered || addParticipantsButton.activeFocus ? DefaultStyle.grey_100 : "transparent"
                        radius: Math.round(4 * DefaultStyle.dp)
					}
					contentItem: RowLayout {
                        spacing: Math.round(8 * DefaultStyle.dp)
						EffectImage {
							imageSource: AppIcons.usersThree
							colorizationColor: DefaultStyle.main2_600
                            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
						}
						Text {
							Layout.fillWidth: true
                            //: "Ajouter des participants"
                            text: qsTr("meeting_schedule_add_participants_title")
							font {
                                pixelSize: Typography.p2l.pixelSize
                                weight: Typography.p2l.weight
							}
						}
					}
					onClicked: mainItem.addParticipantsRequested()
				},
				ListView {
					id: participantList
					Layout.fillWidth: true
					Layout.preferredHeight: contentHeight
                    Layout.maximumHeight: Math.round(250 * DefaultStyle.dp)
					clip: true
					model: mainItem.conferenceInfoGui.core.participants
					delegate: Item {
                        height: Math.round(56 * DefaultStyle.dp)
						width: participantList.width
						RowLayout {
							anchors.fill: parent
                            spacing: Math.round(16 * DefaultStyle.dp)
							Avatar {
                                Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                                Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
								_address: modelData.address
								shadowEnabled: false
							}
							Text {
								property var displayNameObj: UtilsCpp.getDisplayName(modelData.address)
								text: displayNameObj?.value || ""
                                font.pixelSize: Math.round(14 * DefaultStyle.dp)
								font.capitalization: Font.Capitalize
							}
							Item {
								Layout.fillWidth: true
							}
							Button {
                                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                                icon.width: Math.round(24 * DefaultStyle.dp)
                                icon.height: Math.round(24 * DefaultStyle.dp)
                                Layout.rightMargin: Math.round(10 * DefaultStyle.dp)
								icon.source: AppIcons.closeX
								style: ButtonStyle.noBackgroundOrange
								onClicked: mainItem.conferenceInfoGui.core.removeParticipant(index)
							}
						}
					}
				}
			]
		}
		Switch {
            //: "Envoyer une invitation aux participants"
            text: qsTr("meeting_schedule_send_invitations_title")
			checked: mainItem.conferenceInfoGui.core.inviteEnabled
			onToggled: mainItem.conferenceInfoGui.core.inviteEnabled = checked
		}
		Item {
			Layout.fillHeight: true
            Layout.minimumHeight: Math.max(Math.round(1 * DefaultStyle.dp), 1)
		}
	}
}
