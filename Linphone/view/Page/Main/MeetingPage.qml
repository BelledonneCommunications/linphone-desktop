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
	signal returnRequested()
	signal addParticipantsValidated(list<string> selectedParticipants)
	Component.onCompleted: rightPanelStackView.push(overridenRightPanel, Control.StackView.Immediate)

	onSelectedConferenceChanged: {
		overridenRightPanelStackView.clear()
		if (selectedConference) {
			if (!overridenRightPanelStackView.currentItem || overridenRightPanelStackView.currentItem.objectName != "meetingDetail") overridenRightPanelStackView.replace(meetingDetail, Control.StackView.Immediate)
		}
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
			mainItem.selectedConference = confInfoGui
			leftPanelStackView.push(createConf, {"conferenceInfoGui": mainItem.selectedConference, "isCreation": isCreation})
		} else {
			mainItem.selectedConference = confInfoGui
			overridenRightPanelStackView.push(editConf, {"conferenceInfoGui": mainItem.selectedConference, "isCreation": isCreation})
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

	leftPanelContent: Item {
		Layout.fillHeight: true
		Layout.fillWidth: true

		Control.StackView {
			id: leftPanelStackView
			initialItem: listLayout
			anchors.top: parent.top
			anchors.topMargin: 18 * DefaultStyle.dp
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			anchors.leftMargin: 45 * DefaultStyle.dp
		}

		ScrollBar {
			id: meetingsScrollbar
			anchors.right: parent.right
			anchors.rightMargin: 8 * DefaultStyle.dp
			anchors.top: leftPanelStackView.top
			anchors.bottom: parent.bottom
			visible: leftPanelStackView.currentItem == listLayout
			active: true
			interactive: true
			policy: Control.ScrollBar.AsNeeded
		}
	}

	Item {
		id: overridenRightPanel
		Control.StackView {
			id: overridenRightPanelStackView
			width: 393 * DefaultStyle.dp
			height: parent.height
			anchors.top: parent.top
			anchors.centerIn: parent
			anchors.horizontalCenter: parent.horiztonalCenter
		}
	}

	Component {
		id: listLayout
		ColumnLayout {
			property string objectName: "listLayout"
			spacing: 0
			Control.StackView.onDeactivated: {
				mainItem.selectedConference = null
				// mainItem.righPanelStackView.clear()
			}
			Control.StackView.onActivated: {
				mainItem.selectedConference = conferenceList.selectedConference
			}
			RowLayout {
				visible: leftPanelStackView.currentItem.objectName == "listLayout"
				enabled: mainItem.leftPanelEnabled
				Layout.rightMargin: 39 * DefaultStyle.dp
				spacing: 0
				Text {
					Layout.fillWidth: true
					text: qsTr("Réunions")
					color: DefaultStyle.main2_700
					font.pixelSize: 29 * DefaultStyle.dp
					font.weight: 800 * DefaultStyle.dp
				}
				Item{Layout.fillWidth: true}
				Button {
					background: Item {
					}
					icon.source: AppIcons.plusCircle
					Layout.preferredWidth: 28 * DefaultStyle.dp
					Layout.preferredHeight: 28 * DefaultStyle.dp
					icon.width: 28 * DefaultStyle.dp
					icon.height: 28 * DefaultStyle.dp
					onClicked: {
						mainItem.setUpConference()
					}
				}
			}
			SearchBar {
				id: searchBar
				Layout.topMargin: 18 * DefaultStyle.dp
				// Layout.fillWidth: true
				//Layout.topMargin: 18 * DefaultStyle.dp
				placeholderText: qsTr("Rechercher une réunion")
				Layout.preferredWidth: 331 * DefaultStyle.dp
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
			// Remove 24 from first section padding because we cannot know that it is the first section. 24 is the margins between sections.
				Layout.topMargin: 38 * DefaultStyle.dp - 24 * DefaultStyle.dp
				spacing: 0
				MeetingList {
					id: conferenceList
					Layout.fillWidth: true
					Layout.fillHeight: true
					visible: count != 0
					hoverEnabled: mainItem.leftPanelEnabled
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
		ColumnLayout {
			property ConferenceInfoGui conferenceInfoGui
			property bool isCreation

			RowLayout {
				width: 320 * DefaultStyle.dp
				Layout.rightMargin: 35 * DefaultStyle.dp
				Button {
					background: Item{}
					icon.source: AppIcons.leftArrow
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					onClicked: {
						meetingSetup.conferenceInfoGui.core.undo()
						leftPanelStackView.pop()
					}
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
					text: qsTr("Créer")
					textSize: 13 * DefaultStyle.dp
					onClicked: {
						if (meetingSetup.conferenceInfoGui.core.subject.length === 0) {
							UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La conférence doit contenir un sujet"), false)
						} else if (meetingSetup.conferenceInfoGui.core.duration <= 0) {
							UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La fin de la conférence doit être plus récente que son début"), false)
						} else if (meetingSetup.conferenceInfoGui.core.participantCount === 0) {
							UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La conférence doit contenir au moins un participant"), false)
						} else {
							meetingSetup.conferenceInfoGui.core.save()
						}
					}
				}
			}
			MeetingSetUp {
				id: meetingSetup
				conferenceInfoGui: parent.conferenceInfoGui
				isCreation: parent.isCreation
				Layout.rightMargin: 35 * DefaultStyle.dp
				onSaveSucceed: {
					mainItem.newConfCreated()
					leftPanelStackView.pop()
					UtilsCpp.showInformationPopup(qsTr("Nouvelle réunion"), qsTr("Réunion planifiée avec succès"), true)
				}
				onAddParticipantsRequested: {
					leftPanelStackView.push(addParticipants, {"conferenceInfoGui": conferenceInfoGui, "container": leftPanelStackView})
				}
				Connections {
					target: mainItem
					onAddParticipantsValidated: (selectedParticipants) => {
						meetingSetup.conferenceInfoGui.core.resetParticipants(selectedParticipants)
						leftPanelStackView.pop()
					}
				}
			}
		}
	}

	Component {
		id: editConf
		ColumnLayout {
			property bool isCreation
			property ConferenceInfoGui conferenceInfoGui
			Section {
				content: RowLayout {
					spacing: 10 * DefaultStyle.dp
					Button {
						background: Item{}
						icon.source: AppIcons.leftArrow
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						onClicked: {
							conferenceEdit.conferenceInfoGui.core.undo()
							overridenRightPanelStackView.pop()
						}
					}

					TextInput {
						Component.onCompleted: text = mainItem.selectedConference.core.subject
						color: DefaultStyle.main2_600
						font {
							pixelSize: 20 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
						Layout.fillWidth: true
						onActiveFocusChanged: if(activeFocus==true) selectAll()
						onEditingFinished: mainItem.selectedConference.core.subject = text
					}
					Button {
						topPadding: 6 * DefaultStyle.dp
						bottomPadding: 6 * DefaultStyle.dp
						leftPadding: 12 * DefaultStyle.dp
						rightPadding: 12 * DefaultStyle.dp
						text: qsTr("Save")
						textSize: 13 * DefaultStyle.dp
						onClicked: {
							if (mainItem.selectedConference.core.subject.length === 0) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La conférence doit contenir un sujet"), false)
							} else if (mainItem.selectedConference.core.duration <= 0) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La fin de la conférence doit être plus récente que son début"), false)
							} else if (mainItem.selectedConference.core.participantCount === 0) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La conférence doit contenir au moins un participant"), false)
							} else {
								mainItem.selectedConference.core.save()
							}
						}
					}
				}
			}
			MeetingSetUp {
				id: conferenceEdit
				property bool isCreation
				isCreation: parent.isCreation
				conferenceInfoGui: parent.conferenceInfoGui
				onSaveSucceed: {
					overridenRightPanelStackView.pop()
					UtilsCpp.showInformationPopup(qsTr("Enregistré"), qsTr("Réunion modifiée avec succès"), true)
				}
				onAddParticipantsRequested: {
					overridenRightPanelStackView.push(addParticipants, {"conferenceInfoGui": conferenceInfoGui, "container": overridenRightPanelStackView})
				}
				Connections {
					target: mainItem
					onAddParticipantsValidated: (selectedParticipants) => {
						conferenceEdit.conferenceInfoGui.core.resetParticipants(selectedParticipants)
						overridenRightPanelStackView.pop()
					}
				}
			}
		}
	}

	Component {
		id: addParticipants
		ColumnLayout {
			property Control.StackView container
			property ConferenceInfoGui conferenceInfoGui
			RowLayout {
				Button {
					background: Item{}
					icon.source: AppIcons.leftArrow
					contentImageColor: DefaultStyle.main1_500_main
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					icon.width: 24 * DefaultStyle.dp
					icon.height: 24 * DefaultStyle.dp
					onClicked: mainItem.returnRequested()
				}
				ColumnLayout {
					spacing: 3 * DefaultStyle.dp
					Text {
						text: qsTr("Appel de groupe")
						color: DefaultStyle.main1_500_main
						maximumLineCount: 1
						font {
							pixelSize: 18 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
						Layout.fillWidth: true
					}
					Text {
						text: qsTr("%1 participant%2 sélectionné%2").arg(addParticipantLayout.selectedParticipantsCount).arg(addParticipantLayout.selectedParticipantsCount > 1 ? "s" : "")
						color: DefaultStyle.main2_500main
						maximumLineCount: 1
						font {
							pixelSize: 12 * DefaultStyle.dp
							weight: 300 * DefaultStyle.dp
						}
						Layout.fillWidth: true
					}
				}
				Button {
					enabled: addParticipantLayout.selectedParticipantsCount.length != 0
					Layout.rightMargin: 21 * DefaultStyle.dp
					topPadding: 6 * DefaultStyle.dp
					bottomPadding: 6 * DefaultStyle.dp
					leftPadding: 12 * DefaultStyle.dp
					rightPadding: 12 * DefaultStyle.dp
					text: qsTr("Ajouter")
					textSize: 13 * DefaultStyle.dp
					onClicked: {
						mainItem.addParticipantsValidated(addParticipantLayout.selectedParticipants)
					}
				}
			}
			AddParticipantsLayout {
				id: addParticipantLayout
				conferenceInfoGui: parent.conferenceInfoGui
			}
		}
	}

	Component {
		id: meetingDetail
		ColumnLayout {
			visible: mainItem.selectedConference
			spacing: 25 * DefaultStyle.dp
			Section {
				visible: mainItem.selectedConference
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
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
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
									if (mainItem.selectedConference) {
										cancelAndDeleteConfDialog.cancel = UtilsCpp.isMe(mainItem.selectedConference.core.organizerAddress)
										cancelAndDeleteConfDialog.open()
										// mainItem.contactDeletionRequested(mainItem.selectedConference)
										deletePopup.close()
									}
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
							onClicked: {
								UtilsCpp.createCall(mainItem.selectedConference.core.uri)
							}
						}
						Button {
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							icon.width: 24 * DefaultStyle.dp
							icon.height: 24 * DefaultStyle.dp
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
