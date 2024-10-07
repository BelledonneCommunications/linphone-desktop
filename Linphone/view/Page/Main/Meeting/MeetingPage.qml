import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp

// TODO : spacing
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
	signal returnRequested()
	signal addParticipantsValidated(list<string> selectedParticipants)
	Component.onCompleted: rightPanelStackView.push(overridenRightPanel, Control.StackView.Immediate)
	showDefaultItem: leftPanelStackView.currentItem?.objectName === "listLayout" && meetingListCount === 0

	onVisibleChanged: if (!visible) {
		leftPanelStackView.clear()
		leftPanelStackView.push(leftPanelStackView.initialItem)
	}

	onSelectedConferenceChanged: {
		overridenRightPanelStackView.clear()
		if (selectedConference && selectedConference.core.haveModel) {
			if (!overridenRightPanelStackView.currentItem || overridenRightPanelStackView.currentItem != meetingDetail) overridenRightPanelStackView.replace(meetingDetail, Control.StackView.Immediate)
		}
	}

	onNoItemButtonPressed: editConference()

	function editConference(confInfoGui = null) {
		var isCreation = !confInfoGui
		var item
		if (isCreation) {
			confInfoGui = Qt.createQmlObject('import Linphone
											ConferenceInfoGui{
											}', mainItem)
			mainItem.selectedConference = confInfoGui
			item = leftPanelStackView.push(createConf, {"conferenceInfoGui": mainItem.selectedConference, "isCreation": isCreation})
			item.forceActiveFocus()
		} else {
			mainItem.selectedConference = confInfoGui
			item = overridenRightPanelStackView.push(editConf, {"conferenceInfoGui": mainItem.selectedConference, "isCreation": isCreation})
			item.forceActiveFocus()
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
					cancelAndDeleteConfDialog.cancelRequested()
					cancelAndDeleteConfDialog.accepted()
					cancelAndDeleteConfDialog.close()
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

	leftPanelContent: Control.StackView {
		id: leftPanelStackView
		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.leftMargin: 45 * DefaultStyle.dp
		initialItem: listLayout
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
		FocusScope{
			property string objectName: "listLayout"
			Control.StackView.onDeactivated: {
				mainItem.selectedConference = null
			}
			Control.StackView.onActivated: {
				mainItem.selectedConference = conferenceList.selectedConference
			}
			ColumnLayout {
				id: listLayoutIn
				anchors.fill: parent
				spacing: 0
				RowLayout {
					enabled: mainItem.leftPanelEnabled
					Layout.rightMargin: 38 * DefaultStyle.dp
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
							mainItem.editConference()
						}
					}
				}
				SearchBar {
					id: searchBar
					Layout.fillWidth: true
					Layout.topMargin: 18 * DefaultStyle.dp
					Layout.rightMargin: 38 * DefaultStyle.dp
					placeholderText: qsTr("Rechercher une réunion")
					KeyNavigation.up: conferenceList
					KeyNavigation.down: conferenceList
				}
				Text {
					Layout.topMargin: 38 * DefaultStyle.dp
					Layout.fillHeight: true
					Layout.alignment: Qt.AlignHCenter
					text: mainItem.emptyListText
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
					visible: mainItem.showDefaultItem
					Binding on text {
						when: searchBar.text.length !== 0
						value: qsTr("Aucune réunion correspondante")
						restoreMode: Binding.RestoreBindingOrValue
					}
				}
				MeetingListView {
					id: conferenceList
					// Remove 24 from first section padding because we cannot know that it is the first section. 24 is the margins between sections.
					Layout.topMargin: 38 * DefaultStyle.dp - 24 * DefaultStyle.dp
					Layout.fillWidth: true
					Layout.fillHeight: true
					visible: count != 0
					hoverEnabled: mainItem.leftPanelEnabled
					highlightFollowsCurrentItem: true
					preferredHighlightBegin: height/2 - 10
					preferredHighlightEnd: height/2 + 10
					highlightRangeMode: ListView.ApplyRange
					onCountChanged: mainItem.meetingListCount = count
					searchBarText: searchBar.text
					Keys.onPressed: (event) => {
						if(event.key == Qt.Key_Escape){
							searchBar.forceActiveFocus()
							event.accepted = true
						}else if(event.key == Qt.Key_Right){
							overridenRightPanelStackView.currentItem.forceActiveFocus()
							event.accepted = true
						}
					}
					onSelectedConferenceChanged: {
						mainItem.selectedConference = selectedConference
					}
					Control.ScrollBar.vertical: ScrollBar {
						id: meetingsScrollbar
						anchors.right: parent.right
						anchors.rightMargin: 8 * DefaultStyle.dp
						active: true
						interactive: true
						policy: Control.ScrollBar.AsNeeded
						
					}
				}
			}
		}
	}

	Component {
		id: createConf
		FocusScope{
			id: createConfLayout
			property ConferenceInfoGui conferenceInfoGui
			property bool isCreation
			ColumnLayout {
				spacing: 33 * DefaultStyle.dp
				anchors.fill: parent
				RowLayout {
					Layout.rightMargin: 35 * DefaultStyle.dp
					spacing: 5 * DefaultStyle.dp
					Button {
						id: backButton
						background: Item{}
						icon.source: AppIcons.leftArrow
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						topPadding: 6 * DefaultStyle.dp
						bottomPadding: 6 * DefaultStyle.dp
						focus: true
						KeyNavigation.right: createButton
						KeyNavigation.down: meetingSetup
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
					Item {Layout.fillWidth: true}
					Button {
						id: createButton
						Layout.preferredWidth: 57 * DefaultStyle.dp
						topPadding: 6 * DefaultStyle.dp
						bottomPadding: 6 * DefaultStyle.dp
						KeyNavigation.left: backButton
						KeyNavigation.down: meetingSetup
						contentItem: Text {
							text: qsTr("Créer")
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
	
							font {
								pixelSize: 13 * DefaultStyle.dp
								weight: 600 * DefaultStyle.dp
							}
							color: DefaultStyle.grey_0
						}
						onClicked: {
							if (meetingSetup.conferenceInfoGui.core.subject.length === 0) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La conférence doit contenir un sujet"), false)
							} else if (meetingSetup.conferenceInfoGui.core.duration <= 0) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La fin de la conférence doit être plus récente que son début"), false)
							} else if (meetingSetup.conferenceInfoGui.core.participantCount === 0) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La conférence doit contenir au moins un participant"), false)
							} else {
								meetingSetup.conferenceInfoGui.core.save()
								mainWindow.showLoadingPopup(qsTr("Création de la réunion en cours ..."), true)
							}
						}
					}
				}
				MeetingForm {
					id: meetingSetup
					conferenceInfoGui: createConfLayout.conferenceInfoGui
					isCreation: createConfLayout.isCreation
					Layout.fillHeight: true
					Layout.fillWidth: true
					Layout.rightMargin: 35 * DefaultStyle.dp
					Connections {
						target: meetingSetup.conferenceInfoGui ? meetingSetup.conferenceInfoGui.core : null
						function onConferenceSchedulerStateChanged() {
							var mainWin = UtilsCpp.getMainWindow()
							if (meetingSetup.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.AllocationPending
								|| meetingSetup.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Updating) {
								mainWin.showLoadingPopup(qsTr("Création de la réunion en cours..."))
							} else {
								if (meetingSetup.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Error) {
									UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La création de la conférence a échoué"), false)
								}
								mainWin.closeLoadingPopup()
							}
							createConfLayout.enabled = meetingSetup.conferenceInfoGui.core.schedulerState != LinphoneEnums.ConferenceSchedulerState.AllocationPending
						}
						function onSaveFailed() {
							var mainWin = UtilsCpp.getMainWindow()
							mainWin.closeLoadingPopup()
						}
					}
					onSaveSucceed: {
						leftPanelStackView.pop()
						UtilsCpp.showInformationPopup(qsTr("Nouvelle réunion"), qsTr("Réunion planifiée avec succès"), true)
						mainWindow.closeLoadingPopup()
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
	}

	Component {
		id: editConf
		FocusScope{
			id: editFocusScope
			property bool isCreation
			property ConferenceInfoGui conferenceInfoGui
			width : parent.width
			height: editLayout.implicitHeight
			ColumnLayout {
				id: editLayout
				anchors.fill: parent
				spacing: 0
				Section {
					Layout.topMargin: 58 * DefaultStyle.dp
					content: RowLayout {
						spacing: 10 * DefaultStyle.dp
						Button {
							id: backButton
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							icon.width: 24 * DefaultStyle.dp
							icon.height: 24 * DefaultStyle.dp
							icon.source: AppIcons.leftArrow
							KeyNavigation.left: saveButton
							KeyNavigation.right: titleText
							KeyNavigation.down: conferenceEdit
							KeyNavigation.up: conferenceEdit
							onClicked: {
								conferenceEdit.conferenceInfoGui.core.undo()
								overridenRightPanelStackView.pop()
							}
							background: Item{}
						}
	
						TextField {
							id: titleText
							Layout.fillWidth: true
							color: DefaultStyle.main2_600
							font {
								pixelSize: 20 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
							KeyNavigation.left: backButton
							KeyNavigation.right: saveButton
							KeyNavigation.down: conferenceEdit
							KeyNavigation.up: conferenceEdit
							onActiveFocusChanged: if(activeFocus==true) selectAll()
							onEditingFinished: mainItem.selectedConference.core.subject = text
							Component.onCompleted: text = mainItem.selectedConference.core.subject
							background: Item{}
						}
						Button {
							id: saveButton
							topPadding: 6 * DefaultStyle.dp
							bottomPadding: 6 * DefaultStyle.dp
							leftPadding: 12 * DefaultStyle.dp
							rightPadding: 12 * DefaultStyle.dp
							focus: true
							text: qsTr("Save")
							textSize: 13 * DefaultStyle.dp
							KeyNavigation.left: titleText
							KeyNavigation.right: backButton
							KeyNavigation.down: conferenceEdit
							KeyNavigation.up: conferenceEdit
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
				MeetingForm {
					id: conferenceEdit
					property bool isCreation
					isCreation: editFocusScope.isCreation
					conferenceInfoGui: editFocusScope.conferenceInfoGui
					onSaveSucceed: {
						overridenRightPanelStackView.pop()
						UtilsCpp.showInformationPopup(qsTr("Enregistré"), qsTr("Réunion modifiée avec succès"), true)
					}
					onAddParticipantsRequested: {
						overridenRightPanelStackView.push(addParticipants, {"conferenceInfoGui": conferenceInfoGui, "container": overridenRightPanelStackView})
					}
					Connections {
						target: mainItem
						function onAddParticipantsValidated(selectedParticipants) {
							conferenceEdit.conferenceInfoGui.core.resetParticipants(selectedParticipants)
							overridenRightPanelStackView.pop()
						}
					}
					Connections {
						target: conferenceEdit.conferenceInfoGui ? conferenceEdit.conferenceInfoGui.core : null
						function onConferenceSchedulerStateChanged() {
							var mainWin = UtilsCpp.getMainWindow()
							if (conferenceEdit.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Error) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("L'édition de la conférence a échoué"), false)
							}
						}
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
			FocusScope{
				Layout.fillWidth: true
				Layout.preferredHeight: addParticipantsButtons.implicitHeight
				RowLayout {
					id: addParticipantsButtons
					spacing: 5 * DefaultStyle.dp
					Button {
						id: removeButton
						background: Item{}
						icon.source: AppIcons.leftArrow
						contentImageColor: DefaultStyle.main1_500_main
						Layout.preferredWidth: 24 * DefaultStyle.dp
						Layout.preferredHeight: 24 * DefaultStyle.dp
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						KeyNavigation.right: addButton
						KeyNavigation.down: addParticipantLayout
						onClicked: container.pop()
					}
					ColumnLayout {
						spacing: 3 * DefaultStyle.dp
						Text {
							text: qsTr("Ajouter des participants")
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
						id: addButton
						enabled: addParticipantLayout.selectedParticipantsCount.length != 0
						Layout.rightMargin: 21 * DefaultStyle.dp
						topPadding: 6 * DefaultStyle.dp
						bottomPadding: 6 * DefaultStyle.dp
						leftPadding: 12 * DefaultStyle.dp
						rightPadding: 12 * DefaultStyle.dp
						focus: enabled
						text: qsTr("Ajouter")
						textSize: 13 * DefaultStyle.dp
						KeyNavigation.left: removeButton
						KeyNavigation.down: addParticipantLayout
						onClicked: {
							mainItem.addParticipantsValidated(addParticipantLayout.selectedParticipants)
						}
					}
				}
			}
			AddParticipantsForm {
				id: addParticipantLayout
				Layout.fillWidth: true
				Layout.fillHeight: true
				conferenceInfoGui: parent.conferenceInfoGui
			}
		}
	}

	Component {
		id: meetingDetail
		FocusScope{
			width: overridenRightPanelStackView.width
			height: meetingDetailsLayout.implicitHeight
			ColumnLayout {
				id: meetingDetailsLayout
				anchors.fill: parent
				visible: mainItem.selectedConference
				spacing: 25 * DefaultStyle.dp
				Section {
					Layout.topMargin: 58 * DefaultStyle.dp
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
							id: editButton
							property var isMeObj: UtilsCpp.isMe(mainItem.selectedConference?.core.organizerAddress)
							visible: mainItem.selectedConference && isMeObj && isMeObj.value || false
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							icon.width: 24 * DefaultStyle.dp
							icon.height: 24 * DefaultStyle.dp
							icon.source: AppIcons.pencil
							contentImageColor: DefaultStyle.main1_500_main
							KeyNavigation.left: leftPanelStackView.currentItem
							KeyNavigation.right: deletePopup
							KeyNavigation.up: joinButton
							KeyNavigation.down: shareNetworkButton
							background: Item{}
							onClicked: mainItem.editConference(mainItem.selectedConference)
						}
						PopupButton {
							id: deletePopup
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							contentImageColor: DefaultStyle.main1_500_main
							KeyNavigation.left: editButton.visible ? editButton : leftPanelStackView.currentItem
							KeyNavigation.right: leftPanelStackView.currentItem
							KeyNavigation.up: joinButton
							KeyNavigation.down: shareNetworkButton
							
							popup.contentItem: Button {
								color: deletePopup.popupBackgroundColor
								borderColor: deletePopup.popupBackgroundColor
								inversedColors: true
								property var isMeObj: UtilsCpp.isMe(mainItem.selectedConference?.core.organizerAddress)
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
										cancelAndDeleteConfDialog.cancel = isMeObj? isMeObj.value : false
										cancelAndDeleteConfDialog.open()
										// mainItem.contactDeletionRequested(mainItem.selectedConference)
										deletePopup.close()
									}
								}
								Connections {
									target: cancelAndDeleteConfDialog
									function onCancelRequested() {
										mainItem.selectedConference.core.lCancelConferenceInfo()
									}
									function onAccepted() {
										mainItem.selectedConference.core.lDeleteConferenceInfo()
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
								id: linkButton
								Layout.fillWidth: true
								font.bold: shadowEnabled
								text: mainItem.selectedConference ? mainItem.selectedConference.core.uri : ""
								textSize: 14 * DefaultStyle.dp
								textWeight: 400 * DefaultStyle.dp
								underline: true
								inversedColors: true
								color: DefaultStyle.main2_600
								background: Item{}
								Keys.onPressed: (event)=> {
									if (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
										clicked(undefined)
										event.accepted = true;
									}
								}
								KeyNavigation.left: shareNetworkButton
								KeyNavigation.right: shareNetworkButton
								KeyNavigation.up: deletePopup
								KeyNavigation.down: joinButton
								onClicked: {
									// TODO : voir si c'est en audio only quand on clique sur le lien
									UtilsCpp.createCall(mainItem.selectedConference.core.uri)
								}
							}
							Button {
								id: shareNetworkButton
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								icon.width: 24 * DefaultStyle.dp
								icon.height: 24 * DefaultStyle.dp
								background: Item{}
								icon.source: AppIcons.shareNetwork
								KeyNavigation.left: linkButton
								KeyNavigation.right: linkButton
								KeyNavigation.up: deletePopup
								KeyNavigation.down: joinButton
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
							_address: mainItem.selectedConference ? mainItem.selectedConference.core.organizerAddress : ""
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
									_address: modelData.address
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
					id: joinButton
					Layout.fillWidth: true
					text: qsTr("Rejoindre la réunion")
					topPadding: 11 * DefaultStyle.dp
					bottomPadding: 11 * DefaultStyle.dp
					focus: true
					KeyNavigation.up: shareNetworkButton
					KeyNavigation.down: deletePopup
					KeyNavigation.left: leftPanelStackView.currentItem
					KeyNavigation.right: leftPanelStackView.currentItem
					onClicked: {
						console.log(mainItem.selectedConference.core.uri)
						var callsWindow = UtilsCpp.getCallsWindow()
						callsWindow.setupConference(mainItem.selectedConference)
						callsWindow.show()
					}
				}
				Item { Layout.fillHeight: true}
			}
		}
	}
}
