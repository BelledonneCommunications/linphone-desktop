import QtQuick 2.15
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp 1.0

ColumnLayout {
	id: mainItem
	spacing: 8 * DefaultStyle.dp
	property ConferenceInfoGui conferenceInfoGui
	signal addParticipantsRequested()
	signal returnRequested()
	RowLayout {
		Button {
			background: Item{}
			icon.source: AppIcons.leftArrow
			Layout.preferredWidth: 24 * DefaultStyle.dp
			Layout.preferredHeight: 24 * DefaultStyle.dp
			onClicked: mainItem.returnRequested()
		}
		Text {
			text: qsTr("Nouvelle réunion")
			color: DefaultStyle.main2_700
			font {
				pixelSize: 22 * DefaultStyle.dp
				weight: 800 * DefaultStyle.dp
			}
			Layout.fillWidth: true
		}
		Button {
			topPadding: 6 * DefaultStyle.dp
			bottomPadding: 6 * DefaultStyle.dp
			leftPadding: 12 * DefaultStyle.dp
			rightPadding: 12 * DefaultStyle.dp
			text: qsTr("Créer")
			textSize: 13 * DefaultStyle.dp
			onClicked: {
				if (mainItem.conferenceInfoGui.core.subject.length === 0) {
					UtilsCpp.showInformationPopup(qsTr("Erreur lors de la création"), qsTr("La conférence doit contenir un sujet"), false)
				} else if (mainItem.conferenceInfoGui.core.duration <= 0) {
					UtilsCpp.showInformationPopup(qsTr("Erreur lors de la création"), qsTr("La fin de la conférence doit être plus récente que son début"), false)
				} else if (mainItem.conferenceInfoGui.core.participantCount === 0) {
					UtilsCpp.showInformationPopup(qsTr("Erreur lors de la création"), qsTr("La conférence doit contenir au moins un participant"), false)
				} else {
					mainItem.conferenceInfoGui.core.save()
					mainItem.returnRequested()
				}
			}
		}
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
		Layout.fillWidth: true
		Layout.topMargin: 20 * DefaultStyle.dp
		Layout.bottomMargin: 20 * DefaultStyle.dp
		Layout.alignment: Qt.AlignHCenter
		spacing: 20 * DefaultStyle.dp
		CheckableButton {
			Layout.preferredWidth: 151 * DefaultStyle.dp
			icon.source: AppIcons.usersThree
			text: qsTr("Réunion")
			checked: true
		}
		CheckableButton {
			Layout.preferredWidth: 151 * DefaultStyle.dp
			icon.source: AppIcons.slide
			text: qsTr("Broadcast")
		}
	}
	Section {
		content: RowLayout {
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
				onActiveFocusChanged: if(activeFocus==true) selectAll()
				onEditingFinished: mainItem.conferenceInfoGui.core.subject = text
			}
		}
	}
	Section {
		Layout.topMargin: 10 * DefaultStyle.dp
		content: ColumnLayout {
			spacing: 15 * DefaultStyle.dp
			anchors.left: parent.left
			anchors.right: parent.right
			RowLayout {
					Layout.fillWidth: true

				EffectImage {
					imageSource: AppIcons.clock
					colorizationColor: DefaultStyle.main2_600
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
				}
				CalendarComboBox {
					id: startDate
					Layout.fillWidth: true
					Layout.preferredHeight: 30 * DefaultStyle.dp
					onSelectedDateChanged: {
						mainItem.conferenceInfoGui.core.dateTime = UtilsCpp.createDateTime(selectedDate, startHour.selectedHour, startHour.selectedMin)
						endDate.calendar.selectedDate = selectedDate
					}
				}
			}
			RowLayout {
				Item {
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
				}
				StackLayout {
					currentIndex: allDaySwitch.position
					RowLayout {
						TimeComboBox {
							id: startHour
							onSelectedHourChanged: {
								mainItem.conferenceInfoGui.core.dateTime = UtilsCpp.createDateTime(startDate.selectedDate, selectedHour, selectedMin)
								console.log("selected hour", selectedHour, selectedMin)
								endHour.selectedTimeString = Qt.formatDateTime(UtilsCpp.createDateTime(new Date(), selectedHour == 23 ? 0 : selectedHour + 1, selectedMin), "hh:mm")
							}
							onSelectedMinChanged: {
								mainItem.conferenceInfoGui.core.dateTime = UtilsCpp.createDateTime(startDate.selectedDate, selectedHour, selectedMin)
								console.log("selected min", selectedHour, selectedMin)
								endHour.selectedTimeString = Qt.formatDateTime(UtilsCpp.createDateTime(new Date(), selectedHour == 23 ? 0 : selectedHour + 1, selectedMin), "hh:mm")
							}
							Layout.preferredWidth: 94 * DefaultStyle.dp
							Layout.preferredHeight: 30 * DefaultStyle.dp
						}
						TimeComboBox {
							id: endHour
							property date startTime: new Date()
							onSelectedHourChanged: mainItem.conferenceInfoGui.core.endDateTime = UtilsCpp.createDateTime(endDate.selectedDate, selectedHour, selectedMin)
							onSelectedMinChanged: mainItem.conferenceInfoGui.core.endDateTime = UtilsCpp.createDateTime(endDate.selectedDate, selectedHour, selectedMin)
							Layout.preferredWidth: 94 * DefaultStyle.dp
							Layout.preferredHeight: 30 * DefaultStyle.dp
							Component.onCompleted: selectedTimeString = Qt.formatDateTime(UtilsCpp.addSecs(startTime, 3600), "hh:mm")
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
					CalendarComboBox {
						id: endDate
						Layout.fillWidth: true
						Layout.preferredHeight: 30 * DefaultStyle.dp
						onSelectedDateChanged: mainItem.conferenceInfoGui.core.endDateTime = UtilsCpp.createDateTime(selectedDate, 23, 59)
					}
				}
			}
			RowLayout {
				Item {
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
				}
				RowLayout {
					Switch {
						id: allDaySwitch
						text: qsTr("Toute la journée")
					}
				}
			}

			ComboBox {
				id: timeZoneCbox
				Layout.fillWidth: true
				Layout.preferredHeight: 30 * DefaultStyle.dp
				hoverEnabled: true
				listView.implicitHeight: 152 * DefaultStyle.dp
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

			ComboBox {
				id: repeaterCbox
				enabled: false
				Component.onCompleted: console.log("TODO : handle conf repetition")
				constantImageSource: AppIcons.reloadArrow
				Layout.fillWidth: true
				Layout.preferredHeight: height
				height: 30 * DefaultStyle.dp
				width: 307 * DefaultStyle.dp
				weight: 700 * DefaultStyle.dp
				leftMargin: 0
				currentIndex: 0
				background: Rectangle {
					visible: parent.hovered || parent.down
					anchors.fill: parent
					color: DefaultStyle.grey_100
				}
				model: [
					{text: qsTr("Une fois")},
					{text: qsTr("Tous les jours")},
					{text: qsTr("Tous les jours de la semaine (Lun-Ven)")},
					{text: qsTr("Toutes les semaines")},
					{text: qsTr("Tous les mois")}
				]
			}
			

		}
	}
	Section {
		content: RowLayout {
			anchors.left: parent.left
			anchors.right: parent.right
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
				background: Rectangle {
					anchors.fill: parent
					color: descriptionEdit.hovered || descriptionEdit.activeFocus ? DefaultStyle.grey_100 : "transparent"
					radius: 4 * DefaultStyle.dp
				}
				onEditingFinished: mainItem.conferenceInfoGui.core.description = text
			}
		}
	}
	Section {
		content: ColumnLayout {
			anchors.left: parent.left
			anchors.right: parent.right
			Button {
				id: addParticipantsButton
				Layout.fillWidth: true
				Layout.preferredHeight: 30 * DefaultStyle.dp
				background: Rectangle {
					anchors.fill: parent
					color: addParticipantsButton.hovered ? DefaultStyle.grey_100 : "transparent"
					radius: 4 * DefaultStyle.dp
				}
				contentItem: RowLayout {
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
			}
			ListView {
				id: participantList
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.preferredHeight: contentHeight
				Layout.maximumHeight: 250 * DefaultStyle.dp
				clip: true
				model: mainItem.conferenceInfoGui.core.participants
				delegate: Item {
					height: 56 * DefaultStyle.dp
					width: parent.width
					RowLayout {
						anchors.fill: parent
						Avatar {
							Layout.preferredWidth: 45 * DefaultStyle.dp
							Layout.preferredHeight: 45 * DefaultStyle.dp
							address: modelData.address
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
							Layout.rightMargin: 10 * DefaultStyle.dp
							background: Item{}
							icon.source: AppIcons.closeX
							contentImageColor: DefaultStyle.main1_500_main
							onClicked: mainItem.conferenceInfoGui.core.removeParticipant(index)
						}
					}
				}
			}
		}
	}
	Switch {
		text: qsTr("Send invitation to participants")
		Component.onCompleted: {
			console.log("TODO : handle send invitation to participants")
			toggle()
		}
	}
	Item {
		Layout.fillHeight: true
	}
}