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
	rightPanelColor: selectedConference ? DefaultStyle.grey_0 : DefaultStyle.grey_100 
	// disable left panel contact list interaction while a contact is being edited
	property bool leftPanelEnabled: true
	property ConferenceInfoGui selectedConference
	property int meetingListCount
	signal newConfCreated()
	onVisibleChanged: if (visible) rightPanelStackView.push(overridenRightPanel, Control.StackView.Immediate)

	onSelectedConferenceChanged: {
		overridenRightPanelStackView.clear()
		if (selectedConference) {
			if (!overridenRightPanelStackView.currentItem || overridenRightPanelStackView.currentItem.objectName != "meetingDetail") overridenRightPanelStackView.replace(meetingDetail, Control.StackView.Immediate)
		}// else {
			/*if (overridenRightPanelStackView.currentItem && overridenRightPanelStackView.currentItem.objectName === "meetingDetail")*/ 
		// }
	}

	Connections {
		target: leftPanelStackView
		onCurrentItemChanged: {
			mainItem.showDefaultItem = leftPanelStackView.currentItem.objectName == "listLayout" && mainItem.meetingListCount === 0
		}
	}
	onMeetingListCountChanged: showDefaultItem = leftPanelStackView.currentItem.objectName == "listLayout" && meetingListCount === 0

	function setUpConference(confInfoGui = null) {
		var isCreation = !confInfoGui
		if (isCreation) {
			confInfoGui = Qt.createQmlObject('import Linphone
											ConferenceInfoGui{
											}', mainItem)
			leftPanelStackView.push(createConf, {"conferenceInfoGui": confInfoGui, "isCreation": isCreation})
		} else {
			overridenRightPanelStackView.push(editConf, {"conferenceInfoGui": confInfoGui, "isCreation": isCreation})
		}
	}

	Dialog {
		id: cancelAndDeleteConfDialog
		property bool cancel: false
		signal cancelRequested()
		// width: 278 * DefaultStyle.dp
		text: cancel ? qsTr("Souhaitez-vous annuler et supprimer cette réunion ?") : qsTr("Souhaitez-vous supprimer cette réunion ?")
		buttons: [
			Button {
				visible: cancelAndDeleteConfDialog.cancel
				text: qsTr("Annuler et supprimer")
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
				onClicked: {
					cancelAndDeleteConfDialog.accepted()
					cancelAndDeleteConfDialog.close()
					cancelAndDeleteConfDialog.cancelRequested()
				}
			},
			Button {
				text: cancelAndDeleteConfDialog.cancel ? qsTr("Supprimer seulement") : qsTr("Supprimer")
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
				onClicked: {
					cancelAndDeleteConfDialog.accepted()
					cancelAndDeleteConfDialog.close()
				}
			},
			Button {
				text: qsTr("Retour")
				inversedColors: true
				leftPadding: 20 * DefaultStyle.dp
				rightPadding: 20 * DefaultStyle.dp
				topPadding: 11 * DefaultStyle.dp
				bottomPadding: 11 * DefaultStyle.dp
				onClicked: {
					cancelAndDeleteConfDialog.rejected()
					cancelAndDeleteConfDialog.close()
				}
			}
		]
	}

	leftPanelContent: RowLayout {
		id: leftPanel
		Layout.fillWidth: true
		Layout.fillHeight: true
		property int sideMargin: 20 * DefaultStyle.dp

		ColumnLayout {
			// Layout.topMargin: 30 * DefaultStyle.dp
			// Layout.leftMargin: leftPanel.sideMargin
			enabled: mainItem.leftPanelEnabled
			spacing: 30 * DefaultStyle.dp
			Layout.leftMargin: leftPanel.sideMargin
			Layout.rightMargin: leftPanel.sideMargin


			RowLayout {
				visible: leftPanelStackView.currentItem.objectName == "listLayout"
				Layout.fillWidth: true
				// Layout.rightMargin: leftPanel.sideMargin

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
						mainItem.setUpConference()
					}
				}
			}

			Item {
				Layout.fillWidth: true
				Layout.fillHeight: true

				Control.StackView {
					id: leftPanelStackView
					initialItem: listLayout
					anchors.fill: parent
				}
			}
		}

		Control.ScrollBar {
			id: meetingsScrollbar
			visible: leftPanelStackView.currentItem.objectName == "listLayout"
			active: true
			interactive: true
			policy: Control.ScrollBar.AsNeeded
			Layout.fillHeight: true
		}
	}

	Item {
		id: overridenRightPanel
		Control.StackView {
			id: overridenRightPanelStackView
			width: 393 * DefaultStyle.dp
			height: parent.height
			anchors.top: parent.top
			// anchors.bottom: parent.bottom
			// Layout.fillWidth: false
		}
	}

	Component {
		id: listLayout
		ColumnLayout {
			property string objectName: "listLayout"
			spacing: 19 * DefaultStyle.dp
			Control.StackView.onDeactivated: {
				mainItem.selectedConference = null
				// mainItem.righPanelStackView.clear()
			}
			Control.StackView.onActivated: mainItem.selectedConference = conferenceList.selectedConference
			SearchBar {
				id: searchBar
				Layout.fillWidth: true
				placeholderText: qsTr("Rechercher une réunion")
			}

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
			
			RowLayout {
				MeetingList {
					id: conferenceList
					visible: count != 0
					hoverEnabled: mainItem.leftPanelEnabled
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
					Connections {
						target: mainItem
						onNewConfCreated: {
							conferenceList.forceUpdate()
						}
					}
					Control.ScrollBar.vertical: meetingsScrollbar
				}
			}
		}
	}
	Component {
		id: createConf
		MeetingSetUp {
			id: meetingSetup
			onSaveSucceed: {
				mainItem.newConfCreated()
				leftPanelStackView.pop()
				UtilsCpp.showInformationPopup(qsTr("Nouvelle réunion"), qsTr("Réunion planifiée avec succès"), true)
			}
			onReturnRequested: {
				leftPanelStackView.pop()
			}
			onAddParticipantsRequested: {
				leftPanelStackView.push(addParticipants, {"conferenceInfoGui": meetingSetup.conferenceInfoGui, "container": leftPanelStackView})
			}
		}
	}
	Component {
		id: editConf
		MeetingSetUp {
			property bool isCreation
			isCreation: parent.isCreation
			onReturnRequested: {
				overridenRightPanelStackView.pop()
			}
			onSaveSucceed: {
				overridenRightPanelStackView.pop()
				UtilsCpp.showInformationPopup(qsTr("Enregistré"), qsTr("Réunion modifiée avec succès"), true)
			}
			onAddParticipantsRequested: {
				overridenRightPanelStackView.push(addParticipants, {"conferenceInfoGui": conferenceInfoGui, "container": overridenRightPanelStackView})
			}
		}
	}
	Component {
		id: addParticipants
		AddParticipantsLayout {
			id: addParticipantLayout
			property Control.StackView container
			// Layout.fillHeight: true
			title: qsTr("Ajouter des participants")
			validateButtonText: qsTr("Ajouter")
			titleColor: DefaultStyle.main1_500_main
			onReturnRequested: {
				container.pop()
			}
		}
	}
	Component {
		id: meetingDetail
		ColumnLayout {
			visible: mainItem.selectedConference
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
						text: mainItem.selectedConference ? mainItem.selectedConference.core.subject : ""
						font {
							pixelSize: 20 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
					}
					Item {
						Layout.fillWidth: true
					}
					Button {
						visible: mainItem.selectedConference && UtilsCpp.isMe(mainItem.selectedConference.core.organizerAddress)
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						icon.source: AppIcons.pencil
						contentImageColor: DefaultStyle.main1_500_main
						background: Item{}
						onClicked: mainItem.setUpConference(mainItem.selectedConference)
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
									cancelAndDeleteConfDialog.cancel = UtilsCpp.isMe(mainItem.selectedConference.core.organizerAddress)
									cancelAndDeleteConfDialog.open()
									// mainItem.contactDeletionRequested(mainItem.selectedConference)
									deletePopup.close()
								}
								Connections {
									target: cancelAndDeleteConfDialog
									onCancelRequested: {
										mainItem.selectedConference.core.lCancelConferenceInfo()
									}
									onAccepted: {
										mainItem.selectedConference.core.lDeleteConferenceInfo()
									}
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
							text: mainItem.selectedConference ? mainItem.selectedConference.core.uri : ""
							textSize: 14 * DefaultStyle.dp
							textWeight: 400 * DefaultStyle.dp
							underline: true
							inversedColors: true
							color: DefaultStyle.main2_600
							background: Item{}
							property var callObj
							onClicked: {
								callObj = UtilsCpp.createCall(mainItem.selectedConference.core.uri)
							}
						}
						Button {
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							background: Item{}
							icon.source: AppIcons.shareNetwork
							onClicked: {
								UtilsCpp.copyToClipboard(mainItem.selectedConference.core.uri)
								UtilsCpp.showInformationPopup(qsTr("Enregistré"), qsTr("Le lien de la réunion a été copié dans le presse-papiers"))
							}
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
							text: mainItem.selectedConference
									? UtilsCpp.toDateString(mainItem.selectedConference.core.dateTimeUtc) 
									+ " | " + UtilsCpp.toDateHourString(mainItem.selectedConference.core.dateTimeUtc) 
									+ " - " 
									+ UtilsCpp.toDateHourString(mainItem.selectedConference.core.endDateTime)
									: ''
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
							text: qsTr("Time zone: ") + (mainItem.selectedConference ? (mainItem.selectedConference.core.timeZoneModel.displayName + ", " + mainItem.selectedConference.core.timeZoneModel.countryName) : "")
							font {
								pixelSize: 14 * DefaultStyle.dp
								capitalization: Font.Capitalize
							}
						}
					}
				}
			}
			Section {
				visible: mainItem.selectedConference && mainItem.selectedConference.core.description.length != 0
				content: RowLayout {
					spacing: 8 * DefaultStyle.dp
					EffectImage {
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						imageSource: AppIcons.note
						colorizationColor: DefaultStyle.main2_600
					}
					Text {
						text: mainItem.selectedConference ? mainItem.selectedConference.core.description : ""
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
						address: mainItem.selectedConference ? mainItem.selectedConference.core.organizerAddress : ""
					}
					Text {
						text: mainItem.selectedConference ? mainItem.selectedConference.core.organizerName : ""
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
						model: mainItem.selectedConference ? mainItem.selectedConference.core.participants : []
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
								visible: mainItem.selectedConference && mainItem.selectedConference.core.organizerAddress === modelData.address
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
				onClicked: {
					console.log(mainItem.selectedConference.core.uri)
					UtilsCpp.setupConference(mainItem.selectedConference)
				}
			}
			Item { Layout.fillHeight: true}
		}
	}
}
