import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp

FocusScope {
	id: mainItem
	property bool isCreation
	property ConferenceInfoGui conferenceInfoGui
	signal addParticipantsRequested()
	signal returnRequested()
	signal saveSucceed(bool isCreation)

	ColumnLayout {
		id: formLayout
		spacing: 16 * DefaultStyle.dp
		Connections {
			target: mainItem.conferenceInfoGui.core
			function onSchedulerStateChanged() {
				if (mainItem.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Ready) {
					mainItem.saveSucceed(isCreation)
				}
			}
		}

		Component.onCompleted: {
			endHour.selectedDateTime = mainItem.conferenceInfoGui.core.endDateTime
			startHour.selectedDateTime = mainItem.conferenceInfoGui.core.dateTime
			startDate.calendar.selectedDate = mainItem.conferenceInfoGui.core.dateTime
		}

		component CheckableButton: Button {
			id: checkableButton
			checkable: true
			autoExclusive: true
			contentImageColor: checked ? DefaultStyle.grey_0 : DefaultStyle.main1_500_main
			inversedColors: !checked
			topPadding: 10 * DefaultStyle.dp
			bottomPadding: 10 * DefaultStyle.dp
			leftPadding: 16 * DefaultStyle.dp
			rightPadding: 16 * DefaultStyle.dp
			contentItem: RowLayout {
				spacing: 8 * DefaultStyle.dp
				EffectImage {
					imageSource: checkableButton.icon.source
					colorizationColor: checkableButton.checked ? DefaultStyle.grey_0 : DefaultStyle.main1_500_main
					width: 24 * DefaultStyle.dp
					height: 24 * DefaultStyle.dp
				}
				Text {
					text: checkableButton.text
					color: checkableButton.checked ? DefaultStyle.grey_0 : DefaultStyle.main1_500_main
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 400 * DefaultStyle.dp
					}
				}
			}
		}

		RowLayout {
			visible: mainItem.isCreation && !SettingsCpp.disableBroadcastFeature
			Layout.topMargin: 20 * DefaultStyle.dp
			Layout.bottomMargin: 20 * DefaultStyle.dp
			spacing: 18 * DefaultStyle.dp
			CheckableButton {
				Layout.preferredWidth: 151 * DefaultStyle.dp
				icon.source: AppIcons.usersThree
				icon.width: 24 * DefaultStyle.dp
				icon.height: 24 * DefaultStyle.dp
				enabled: false
				text: qsTr("Réunion")
				checked: true
			}
			CheckableButton {
				Layout.preferredWidth: 151 * DefaultStyle.dp
				enabled: false
				icon.source: AppIcons.slide
				icon.width: 24 * DefaultStyle.dp
				icon.height: 24 * DefaultStyle.dp
				text: qsTr("Broadcast")
			}
		}
		Section {
			visible: mainItem.isCreation
			spacing: formLayout.spacing
			content: RowLayout {
				spacing: 8 * DefaultStyle.dp
				EffectImage {
					imageSource: AppIcons.usersThree
					colorizationColor: DefaultStyle.main2_600
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
				}
				TextInput {
					id: confTitle
					text: qsTr("Ajouter un titre")
					color: DefaultStyle.main2_600
					font {
						pixelSize: 20 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
					focus: true
					onActiveFocusChanged: if(activeFocus) selectAll()
					onEditingFinished: mainItem.conferenceInfoGui.core.subject = text
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
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
					}
					CalendarComboBox {
						id: startDate
						background.visible: mainItem.isCreation
						indicator.visible: mainItem.isCreation
						contentText.font.weight: (isCreation ? 700 : 400) * DefaultStyle.dp
						Layout.fillWidth: true
						Layout.preferredHeight: 30 * DefaultStyle.dp
						KeyNavigation.up: confTitle
						KeyNavigation.down: startHour
						onSelectedDateChanged: {
							if (!selectedDate || selectedDate == mainItem.conferenceInfoGui.core.dateTime) return
							mainItem.conferenceInfoGui.core.dateTime = UtilsCpp.createDateTime(selectedDate, startHour.selectedHour, startHour.selectedMin)
							if (isCreation) {
								startHour.selectedDateTime = UtilsCpp.createDateTime(selectedDate, startHour.selectedHour, startHour.selectedMin)
							}
						}
					}
				},
				RowLayout {
					Item {
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
					}
					RowLayout {
						TimeComboBox {
							id: startHour
							indicator.visible: mainItem.isCreation
							// Layout.fillWidth: true
							Layout.preferredWidth: 94 * DefaultStyle.dp
							Layout.preferredHeight: 30 * DefaultStyle.dp
							background.visible: mainItem.isCreation
							contentText.font.weight: (isCreation ? 700 : 400) * DefaultStyle.dp
							KeyNavigation.up: startDate
							KeyNavigation.down: timeZoneCbox
							KeyNavigation.left: startDate
							KeyNavigation.right: endHour
							onSelectedDateTimeChanged: {
								endHour.minTime = selectedDateTime
								endHour.maxTime = UtilsCpp.createDateTime(selectedDateTime, 23, 59)
								mainItem.conferenceInfoGui.core.dateTime = selectedDateTime
								endHour.selectedDateTime = UtilsCpp.addSecs(selectedDateTime, 3600)
							}
						}
						TimeComboBox {
							id: endHour
							indicator.visible: mainItem.isCreation
							Layout.preferredWidth: 94 * DefaultStyle.dp
							Layout.preferredHeight: 30 * DefaultStyle.dp
							background.visible: mainItem.isCreation
							contentText.font.weight: (isCreation ? 700 : 400) * DefaultStyle.dp
							onSelectedDateTimeChanged: mainItem.conferenceInfoGui.core.endDateTime = selectedDateTime
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
								pixelSize: 14 * DefaultStyle.dp
								weight: 700 * DefaultStyle.dp
							}
						}
					}
				},

				ComboBox {
					id: timeZoneCbox
					Layout.preferredWidth: 307 * DefaultStyle.dp
					Layout.preferredHeight: 30 * DefaultStyle.dp
					hoverEnabled: true
					listView.implicitHeight: 250 * DefaultStyle.dp
					constantImageSource: AppIcons.globe
					weight: 700 * DefaultStyle.dp
					leftMargin: 0
					currentIndex: mainItem.conferenceInfoGui ? model.getIndex(mainItem.conferenceInfoGui.core.timeZoneModel) : -1
					background: Rectangle {
						visible: parent.hovered || parent.down
						anchors.fill: parent
						color: DefaultStyle.grey_100
					}
					model: TimeZoneProxy{
					}
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
				spacing: 8 * DefaultStyle.dp
				EffectImage {
					imageSource: AppIcons.note
					colorizationColor: DefaultStyle.main2_600
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
				}
				TextArea {
					id: descriptionEdit
					Layout.fillWidth: true
					Layout.preferredWidth: 275 * DefaultStyle.dp
					leftPadding: 8 * DefaultStyle.dp
					rightPadding: 8 * DefaultStyle.dp
					hoverEnabled: true
					placeholderText: qsTr("Ajouter une description")
					placeholderTextColor: DefaultStyle.main2_600
					placeholderWeight: 700 * DefaultStyle.dp
					color: DefaultStyle.main2_600
					font {
						pixelSize: 14 * DefaultStyle.dp
						weight: 400 * DefaultStyle.dp
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
						radius: 4 * DefaultStyle.dp
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
					Layout.preferredHeight: 30 * DefaultStyle.dp
					background: Rectangle {
						anchors.fill: parent
						color: addParticipantsButton.hovered || addParticipantsButton.activeFocus ? DefaultStyle.grey_100 : "transparent"
						radius: 4 * DefaultStyle.dp
					}
					contentItem: RowLayout {
						spacing: 8 * DefaultStyle.dp
						EffectImage {
							imageSource: AppIcons.usersThree
							colorizationColor: DefaultStyle.main2_600
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
						}
						Text {
							Layout.fillWidth: true
							text: qsTr("Ajouter des participants")
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 700 * DefaultStyle.dp
							}
						}
					}
					onClicked: mainItem.addParticipantsRequested()
				},
				ListView {
					id: participantList
					Layout.fillWidth: true
					Layout.preferredHeight: contentHeight
					Layout.maximumHeight: 250 * DefaultStyle.dp
					clip: true
					model: mainItem.conferenceInfoGui.core.participants
					delegate: Item {
						height: 56 * DefaultStyle.dp
						width: participantList.width
						RowLayout {
							anchors.fill: parent
							spacing: 16 * DefaultStyle.dp
							Avatar {
								Layout.preferredWidth: 45 * DefaultStyle.dp
								Layout.preferredHeight: 45 * DefaultStyle.dp
								_address: modelData.address
							}
							Text {
								text: modelData.displayName
								font.pixelSize: 14 * DefaultStyle.dp
								font.capitalization: Font.Capitalize
							}
							Item {
								Layout.fillWidth: true
							}
							Button {
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								icon.width: 24 * DefaultStyle.dp
								icon.height: 24 * DefaultStyle.dp
								Layout.rightMargin: 10 * DefaultStyle.dp
								background: Item{}
								icon.source: AppIcons.closeX
								contentImageColor: DefaultStyle.main1_500_main
								onClicked: mainItem.conferenceInfoGui.core.removeParticipant(index)
							}
						}
					}
				}
			]
		}
		Switch {
			text: qsTr("Send invitation to participants")
			checked: mainItem.conferenceInfoGui.core.inviteEnabled
			onToggled: mainItem.conferenceInfoGui.core.inviteEnabled = checked
		}
		Item {
			Layout.fillHeight: true
			Layout.minimumHeight: 1 * DefaultStyle.dp
		}
	}
}
