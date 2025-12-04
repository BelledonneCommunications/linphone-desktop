import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

FocusScope {
	id: mainItem
	height: childrenRect.height
	property bool isCreation
	property ConferenceInfoGui conferenceInfoGui
	signal addParticipantsRequested()

	ColumnLayout {
		id: formLayout
        spacing: Utils.getSizeWithScreenRatio(16)
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top

		Component.onCompleted: {
			endHour.selectedDateTime = mainItem.conferenceInfoGui.core.endDateTime
			startHour.selectedDateTime = mainItem.conferenceInfoGui.core.dateTime
			startDate.calendar.selectedDate = mainItem.conferenceInfoGui.core.dateTime
		}

		RowLayout {
			visible: mainItem.isCreation && !SettingsCpp.disableBroadcastFeature
            Layout.topMargin: Utils.getSizeWithScreenRatio(20)
            Layout.bottomMargin: Utils.getSizeWithScreenRatio(20)
            spacing: Utils.getSizeWithScreenRatio(18)
			CheckableButton {
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(151)
				icon.source: AppIcons.usersThree
                icon.width: Utils.getSizeWithScreenRatio(24)
                icon.height: Utils.getSizeWithScreenRatio(24)
				enabled: false
                //: "Réunion"
                text: qsTr("meeting_schedule_meeting_label")
				checked: true
				autoExclusive: true
				style: ButtonStyle.secondary
			}
			CheckableButton {
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(151)
				enabled: false
				icon.source: AppIcons.slide
                icon.width: Utils.getSizeWithScreenRatio(24)
                icon.height: Utils.getSizeWithScreenRatio(24)
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
                spacing: Utils.getSizeWithScreenRatio(8)
				EffectImage {
					imageSource: AppIcons.usersThree
					colorizationColor: DefaultStyle.main2_600
                    width: Utils.getSizeWithScreenRatio(24)
                    height: Utils.getSizeWithScreenRatio(24)
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
				}
				TextInput {
					id: confTitle
					Layout.fillWidth: true
					maximumLength: width
                    //: "Ajouter un titre"
                    property string defaultText: qsTr("meeting_schedule_subject_hint")
					Component.onCompleted: text = defaultText
					text: conferenceInfoGui.core.subject ? conferenceInfoGui.core.subject : ""
					color: DefaultStyle.main2_600
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(20)
                        weight: Typography.h3.weight
					}
					focus: true
					onActiveFocusChanged: if(activeFocus) {
						if (text == defaultText)
							clear()
						else selectAll()
					} else if (text.length === 0) text = defaultText
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
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
					}
					CalendarComboBox {
						id: startDate
						background.visible: mainItem.isCreation
						indicator.visible: mainItem.isCreation
                        contentText.font.weight: isCreation ? Font.Bold : Font.Normal
						Layout.fillWidth: true
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
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
                        Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
					}
					RowLayout {
						TimeComboBox {
							id: startHour
							// indicator.visible: mainItem.isCreation
                            Layout.preferredWidth: Utils.getSizeWithScreenRatio(94)
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
							background.visible: mainItem.isCreation
                            contentText.font.weight: isCreation ? Font.Bold : Font.Normal
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
                            Layout.preferredWidth: Utils.getSizeWithScreenRatio(94)
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
							background.visible: mainItem.isCreation
                            contentText.font.weight: isCreation ? Font.Bold : Font.Normal
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
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
					hoverEnabled: true
					oneLine: true
                    listView.implicitHeight: Utils.getSizeWithScreenRatio(250)
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
                spacing: Utils.getSizeWithScreenRatio(8)
				EffectImage {
					imageSource: AppIcons.note
					colorizationColor: DefaultStyle.main2_600
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
				}
				TextArea {
					id: descriptionEdit
					Layout.fillWidth: true
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(275)
					Layout.preferredHeight: contentHeight
                    leftPadding: Utils.getSizeWithScreenRatio(8)
                    rightPadding: Utils.getSizeWithScreenRatio(8)
                    //: "Ajouter une description"
                    placeholderText: qsTr("meeting_schedule_description_hint")
					placeholderTextColor: DefaultStyle.main2_600
                    placeholderWeight: Typography.p2l.weight
					color: DefaultStyle.main2_600
					wrapMode: TextEdit.Wrap
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
					KeyNavigation.tab: addParticipantsButton
					background: Rectangle {
						anchors.fill: parent
						color: descriptionEdit.hovered || descriptionEdit.activeFocus ? DefaultStyle.grey_100 : "transparent"
                        radius: Utils.getSizeWithScreenRatio(4)
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
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
					leftPadding: 0
					background: Rectangle {
						anchors.fill: parent
						color: addParticipantsButton.hovered || addParticipantsButton.activeFocus ? DefaultStyle.grey_100 : "transparent"
                        radius: Utils.getSizeWithScreenRatio(4)
					}
					contentItem: RowLayout {
                        spacing: Utils.getSizeWithScreenRatio(8)
						EffectImage {
							imageSource: AppIcons.usersThree
							colorizationColor: DefaultStyle.main2_600
                            Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
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
                    Layout.maximumHeight: Utils.getSizeWithScreenRatio(250)
					clip: true
					model: mainItem.conferenceInfoGui.core.participants
					Control.ScrollBar.vertical: ScrollBar {
						id: participantScrollBar
						anchors.right: participantList.right
						anchors.top: participantList.top
						anchors.bottom: participantList.bottom
						visible: participantList.height < participantList.contentHeight
					}
					delegate: Item {
                        height: Utils.getSizeWithScreenRatio(56)
						width: participantList.width - participantScrollBar.width
						RowLayout {
							anchors.fill: parent
                            spacing: Utils.getSizeWithScreenRatio(16)
							Avatar {
                                Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
								_address: modelData.address
								secured: friendSecurityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
								shadowEnabled: false
							}
							Text {
								property var displayNameObj: UtilsCpp.getDisplayName(modelData.address)
								text: displayNameObj?.value || ""
                                font.pixelSize: Utils.getSizeWithScreenRatio(14)
								font.capitalization: Font.Capitalize
							}
							Item {
								Layout.fillWidth: true
							}
							Button {
                                Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
                                icon.width: Utils.getSizeWithScreenRatio(24)
                                icon.height: Utils.getSizeWithScreenRatio(24)
                                Layout.rightMargin: Utils.getSizeWithScreenRatio(10)
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
			leftPadding: 0
		}
		Item {
			Layout.fillHeight: true
            Layout.minimumHeight: Utils.getSizeWithScreenRatio(1)
		}
	}
}
