import QtQuick 2.15
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp 1.0

AbstractMainPage {
	id: mainItem
	noItemButtonText: qsTr("Créer une réunion")
	emptyListText: qsTr("Aucune réunion")
	newItemIconSource: AppIcons.plusCircle
	// rightPanel.color: DefaultStyle.grey_0 

	// disable left panel contact list interaction while a contact is being edited
	property bool leftPanelEnabled: true
	property ConferenceInfoGui selectedConference
	property int meetingListCount

	onSelectedConferenceChanged: {
		if (selectedConference) {
			if (!rightPanelStackView.currentItem || rightPanelStackView.currentItem.objectName != "meetingDetail") rightPanelStackView.replace(meetingDetail, Control.StackView.Immediate)
		} else {
			if (rightPanelStackView.currentItem && rightPanelStackView.currentItem.objectName === "meetingDetail") rightPanelStackView.clear()
		}
	}

	Connections {
		target: leftPanelStackView
		onCurrentItemChanged: {
			mainItem.showDefaultItem = leftPanelStackView.currentItem.objectName == "listLayout" && mainItem.meetingListCount === 0
		}
	}
	onMeetingListCountChanged: showDefaultItem = leftPanelStackView.currentItem.objectName == "listLayout" && meetingListCount === 0

	function createConference(name, address) {
		var confInfoGui = Qt.createQmlObject('import Linphone
											ConferenceInfoGui{
											}', mainItem)
		leftPanelStackView.push(createConference, {"conferenceInfoGui": confInfoGui})
	}

	leftPanelContent: ColumnLayout {
		id: leftPanel
		Layout.fillWidth: true
		Layout.fillHeight: true
		property int sideMargin: 25 * DefaultStyle.dp

		ColumnLayout {
			Layout.topMargin: 30 * DefaultStyle.dp
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin
			enabled: mainItem.leftPanelEnabled
			Item {
				Layout.fillWidth: true
				Layout.fillHeight: true

				Control.ScrollBar {
					id: meetingsScrollbar
					active: true
					interactive: true
					policy: Control.ScrollBar.AsNeeded
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					anchors.right: parent.right
				}
				Control.StackView {
					id: leftPanelStackView
					initialItem: listLayout
					anchors.fill: parent
				}
				Component {
					id: listLayout
					ColumnLayout {
						spacing: 19 * DefaultStyle.dp
						RowLayout {
							Layout.fillWidth: true
							Layout.leftMargin: leftPanel.sideMargin
							Layout.rightMargin: leftPanel.sideMargin
							Text {
								text: qsTr("Réunions")
								color: DefaultStyle.main2_700
								font.pixelSize: 29 * DefaultStyle.dp
								font.weight: 800 * DefaultStyle.dp
							}
							Item {
								Layout.fillWidth: true
							}
							Button {
								background: Item {
								}
								icon.source: AppIcons.plusCircle
								Layout.preferredWidth: 30 * DefaultStyle.dp
								Layout.preferredHeight: 30 * DefaultStyle.dp
								width: 30 * DefaultStyle.dp
								height: 30 * DefaultStyle.dp
								onClicked: {
									mainItem.createConference()
								}
							}
						}

						SearchBar {
							id: searchBar
							Layout.rightMargin: leftPanel.sideMargin
							Layout.fillWidth: true
							placeholderText: qsTr("Rechercher une réunion")
						}
						Control.ScrollView {
							Layout.fillWidth: true
							Layout.fillHeight: true
							rightPadding: leftPanel.sideMargin
							contentWidth: width - leftPanel.sideMargin
							contentHeight: content.height
							clip: true
							Control.ScrollBar.vertical: meetingsScrollbar
							ColumnLayout {
								id: content
								width: parent.width
								anchors.topMargin: 5 * DefaultStyle.dp
								anchors.fill: parent
								spacing: 15 * DefaultStyle.dp
								Text {
									Layout.fillHeight: true
									Layout.alignment: Qt.AlignHCenter
									text: mainItem.emptyListText
									font {
										pixelSize: 16 * DefaultStyle.dp
										weight: 800 * DefaultStyle.dp
									}
									visible: mainItem.showDefaultItem
								}
								
								MeetingList {
									id: conferenceList
									visible: count != 0
									hoverEnabled: mainItem.leftPanelEnabled
									Layout.preferredWidth: parent.width
									Layout.fillWidth: true
									Layout.fillHeight: true
									Layout.topMargin: 20 * DefaultStyle.dp
									searchBarText: searchBar.text
									onSelectedConferenceChanged: {
										mainItem.selectedConference = selectedConference
									}
									onCountChanged: {
										mainItem.meetingListCount = count
									}
								}
							}
						}
					}
				}
				Component {
					id: createConference
					NewMeeting {
						onReturnRequested: leftPanelStackView.pop()
						onAddParticipantsRequested: {
							onClicked: leftPanelStackView.push(addParticipants, {"conferenceInfoGui": conferenceInfoGui})
						}
					}
				}
				Component {
					id: addParticipants
					AddParticipantsLayout {
						title: qsTr("Ajouter des participants")
						validateButtonText: qsTr("Ajouter")
						titleColor: DefaultStyle.main1_500_main
						onReturnRequested: {
							leftPanelStackView.pop()
						}
					}
				}
			}
		}
	}
	
	Component {
		id: meetingDetail
		RowLayout {
			ColumnLayout {
				Layout.alignment: Qt.AlignTop
				Layout.preferredWidth: 393 * DefaultStyle.dp
				Layout.fillWidth: false
				Layout.fillHeight: true
				Layout.leftMargin: 39 * DefaultStyle.dp
				Layout.topMargin: 39 * DefaultStyle.dp
				spacing: 25 * DefaultStyle.dp
				Section {
					content: RowLayout {
						spacing: 8 * DefaultStyle.dp
						Image {
							source: AppIcons.usersThree
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
						}
						Text {
							text: mainItem.selectedConference.core.subject
							font {
								pixelSize: 20 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
						Item {
							Layout.fillWidth: true
						}
						Button {
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							icon.source: AppIcons.pencil
							contentImageColor: DefaultStyle.main1_500_main
							background: Item{}
							onClicked: mainItem.rightPanelStackView.replace()
						}
						PopupButton {
							id: deletePopup
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							contentImageColor: DefaultStyle.main1_500_main
							popup.contentItem: RowLayout {
								Button {
									background: Item{}
									contentItem: RowLayout {
										EffectImage {
											imageSource: AppIcons.trashCan
											width: 24 * DefaultStyle.dp
											height: 24 * DefaultStyle.dp
											Layout.preferredWidth: 24 * DefaultStyle.dp
											Layout.preferredHeight: 24 * DefaultStyle.dp
											fillMode: Image.PreserveAspectFit
											colorizationColor: DefaultStyle.danger_500main
										}
										Text {
											text: qsTr("Delete this meeting")
											color: DefaultStyle.danger_500main
											font {
												pixelSize: 14 * DefaultStyle.dp
												weight: 400 * DefaultStyle.dp
											}
										}
									}
									onClicked: {
										if (UtilsCpp.isMe(mainItem.selectedConference.core.organizerAddress))
											mainItem.selectedConference.core.lDeleteConferenceInfo()
										else
											UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Vous pouvez supprimer une conférence seulement si vous en êtes l'organisateur"), false)
										// mainItem.contactDeletionRequested(mainItem.selectedConference)
										deletePopup.close()
									}
								}
							}
						}
					}
				}
				Section {
					content: ColumnLayout {
						spacing: 15 * DefaultStyle.dp
						width: parent.width
						RowLayout {
							spacing: 8 * DefaultStyle.dp
							Layout.fillWidth: true
							Image {
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								source: AppIcons.videoCamera
							}
							Button {
								Layout.fillWidth: true
								text: mainItem.selectedConference.core.uri
								textSize: 14 * DefaultStyle.dp
								textWeight: 400 * DefaultStyle.dp
								underline: true
								inversedColors: true
								color: DefaultStyle.main2_600
								background: Item{}
								onClicked: {
									console.log("TODO: join conf", text)
								}
							}
							Button {
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								background: Item{}
								icon.source: AppIcons.shareNetwork
								onClicked: UtilsCpp.copyToClipboard(confUri.text)
							}
						}
						RowLayout {
							spacing: 8 * DefaultStyle.dp
							Image {
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								source: AppIcons.clock
							}
							Text {
								text: UtilsCpp.toDateString(mainItem.selectedConference.core.dateTimeUtc) 
								+ " | " + UtilsCpp.toDateHourString(mainItem.selectedConference.core.dateTimeUtc) 
								+ " - " 
								+ UtilsCpp.toDateHourString(mainItem.selectedConference.core.endDateTime)
								font {
									pixelSize: 14 * DefaultStyle.dp
									capitalization: Font.Capitalize
								}
							}
						}
						RowLayout {
							spacing: 8 * DefaultStyle.dp
							Image {
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								source: AppIcons.globe
							}
							Text {
								text: qsTr("Time zone: ") + mainItem.selectedConference.core.timeZoneModel.displayName + ", " + mainItem.selectedConference.core.timeZoneModel.countryName
								font {
									pixelSize: 14 * DefaultStyle.dp
									capitalization: Font.Capitalize
								}
							}
						}
					}
				}
				Section {
					visible: mainItem.selectedConference.core.description.length != 0
					content: RowLayout {
						spacing: 8 * DefaultStyle.dp
						EffectImage {
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							imageSource: AppIcons.note
							colorizationColor: DefaultStyle.main2_600
						}
						Text {
							text: mainItem.selectedConference.core.description
							Layout.fillWidth: true
							font {
								pixelSize: 14 * DefaultStyle.dp
								capitalization: Font.Capitalize
							}
						}
					}
				}
				Section {
					content: RowLayout {
						spacing: 8 * DefaultStyle.dp
						EffectImage {
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							imageSource: AppIcons.userRectangle
							colorizationColor: DefaultStyle.main2_600
						}
						Avatar {
							Layout.preferredWidth: 45 * DefaultStyle.dp
							Layout.preferredHeight: 45 * DefaultStyle.dp
							address: mainItem.selectedConference.core.organizerAddress
						}
						Text {
							text: mainItem.selectedConference.core.organizerName
							font {
								pixelSize: 14 * DefaultStyle.dp
								capitalization: Font.Capitalize
							}
						}
					}
				}
				Section {
					content: RowLayout {
						Layout.preferredHeight: participantList.height
						width: 393 * DefaultStyle.dp
						spacing: 8 * DefaultStyle.dp
						Image {
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							Layout.alignment: Qt.AlignLeft | Qt.AlignTop
							Layout.topMargin: 20 * DefaultStyle.dp
							source: AppIcons.usersTwo
						}
						ListView {
							id: participantList
							Layout.preferredHeight: Math.min(184 * DefaultStyle.dp, contentHeight)
							Layout.fillWidth: true
							model: mainItem.selectedConference.core.participants
							clip: true
							delegate: RowLayout {
								height: 56 * DefaultStyle.dp
								width: participantList.width
								Avatar {
									Layout.preferredWidth: 45 * DefaultStyle.dp
									Layout.preferredHeight: 45 * DefaultStyle.dp
									address: modelData.address
								}
								Text {
									text: modelData.displayName
									Layout.fillWidth: true
									font {
										pixelSize: 14 * DefaultStyle.dp
										capitalization: Font.Capitalize
									}
								}
								Text {
									text: qsTr("Organizer")
									visible: mainItem.selectedConference.core.organizerAddress === modelData.address
									color: DefaultStyle.main2_400
									font {
										pixelSize: 12 * DefaultStyle.dp
										weight: 300 * DefaultStyle.dp
									}
								}
							}
						}
					}
				}
				Button {
					Layout.fillWidth: true
					text: qsTr("Rejoindre la réunion")
					topPadding: 11 * DefaultStyle.dp
					bottomPadding: 11 * DefaultStyle.dp
					onClicked: console.log("TODO: join conf", mainItem.selectedConference.core.subject)
				}
			}
		}
	}
	Component {
		id: meetingEdition
		Section {
			content: RowLayout {
				spacing: 8 * DefaultStyle.dp
				Button {
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					icon.source: AppIcons.leftArrow
					contentImageColor: DefaultStyle.main1_500_main
					background: Item{}
					onClicked: mainItem.rightPanelStackView.pop()
				}
				Image {
					source: AppIcons.usersThree
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
				}
				Text {
					text: mainItem.selectedConference.core.subject
					font {
						pixelSize: 20 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				Item {
					Layout.fillWidth: true
				}
				Button {
					text: qsTr("Save")
					onClicked: {
						console.log("TODO : save meeting infos")
						mainItem.rightPanelStackView.pop(meetingDetail, Control.StackView.Immediate)
					}
				}
			}
		}
	}
}
