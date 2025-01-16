import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

// TODO : spacing
AbstractMainPage {
	id: mainItem
	
	property ConferenceInfoGui selectedConference
	property int meetingListCount
	signal returnRequested()
	signal addParticipantsValidated(list<string> selectedParticipants)
	
	noItemButtonText: qsTr("Créer une réunion")
	emptyListText: qsTr("Aucune réunion")
	newItemIconSource: AppIcons.plusCircle
	rightPanelColor: selectedConference ? DefaultStyle.grey_0 : DefaultStyle.grey_100 
	showDefaultItem: leftPanelStackView.currentItem?.objectName === "listLayout" && meetingListCount === 0


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
	
	
	onVisibleChanged: if (!visible) {
		leftPanelStackView.clear()
		leftPanelStackView.push(leftPanelStackView.initialItem)
		
	}

	onSelectedConferenceChanged: {
		// While a conference is being edited, we need to stay on the edit page
		if (overridenRightPanelStackView.currentItem && (overridenRightPanelStackView.currentItem.objectName === "editConf" || overridenRightPanelStackView.currentItem.objectName === "createConf")) return
		overridenRightPanelStackView.clear()
		if (selectedConference && selectedConference.core && selectedConference.core.haveModel) {
			if (!overridenRightPanelStackView.currentItem || overridenRightPanelStackView.currentItem != meetingDetail) overridenRightPanelStackView.replace(meetingDetail, Control.StackView.Immediate)
		}
	}

	onNoItemButtonPressed: editConference()
	
	Component.onCompleted: rightPanelStackView.push(overridenRightPanel, Control.StackView.Immediate)
	
	leftPanelContent: Control.StackView {
		id: leftPanelStackView
		Layout.fillWidth: true
		Layout.fillHeight: true
		Layout.leftMargin: 45 * DefaultStyle.dp
		initialItem: listLayout
		clip: true
	}

	Dialog {
		id: cancelAndDeleteConfDialog
		property bool cancel: false
		signal cancelRequested()
		// width: 278 * DefaultStyle.dp
		text: cancel ? qsTr("Souhaitez-vous annuler et supprimer cette réunion ?") : qsTr("Souhaitez-vous supprimer cette réunion ?")
		buttons: [
			BigButton {
				visible: cancelAndDeleteConfDialog.cancel
				style: ButtonStyle.main
				text: qsTr("Annuler et supprimer")
				onClicked: {
					cancelAndDeleteConfDialog.cancelRequested()
					cancelAndDeleteConfDialog.accepted()
					cancelAndDeleteConfDialog.close()
				}
			},
			BigButton {
				text: cancelAndDeleteConfDialog.cancel ? qsTr("Supprimer seulement") : qsTr("Supprimer")
				style: ButtonStyle.main
				onClicked: {
					cancelAndDeleteConfDialog.accepted()
					cancelAndDeleteConfDialog.close()
				}
			},
			BigButton {
				text: qsTr("Retour")
				style: ButtonStyle.secondary
				onClicked: {
					cancelAndDeleteConfDialog.rejected()
					cancelAndDeleteConfDialog.close()
				}
			}
		]
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
			enabled: !overridenRightPanelStackView.currentItem || overridenRightPanelStackView.currentItem.objectName !== "editConf"
			
			ColumnLayout {
				anchors.fill: parent
				spacing: 0 
				RowLayout {
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
						style: ButtonStyle.noBackground
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
					Binding {
						target: mainItem
						property: "showDefaultItem"
						when: searchBar.text.length !== 0
						value: false
					}
				}
				Text {
					visible: conferenceList.count === 0
					Layout.topMargin: 137 * DefaultStyle.dp
					Layout.fillHeight: true
					Layout.alignment: Qt.AlignHCenter
					text: qsTr("Aucune réunion%1").arg(searchBar.text.length !== 0 ? " correspondante" : "")
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				MeetingListView {
					id: conferenceList
					// Remove 24 from first section padding because we cannot know that it is the first section. 24 is the margins between sections.
					Layout.topMargin: 38 * DefaultStyle.dp - 24 * DefaultStyle.dp
					Layout.fillWidth: true
					Layout.fillHeight: true
					
					searchBarText: searchBar.text
					
					onCountChanged: mainItem.meetingListCount = count
					onSelectedConferenceChanged: {
						mainItem.selectedConference = selectedConference
					}
					
					Keys.onPressed: (event) => {
						if(event.key == Qt.Key_Escape){
							searchBar.forceActiveFocus()
							event.accepted = true
						}else if(event.key == Qt.Key_Right){
							overridenRightPanelStackView.currentItem.forceActiveFocus()
							event.accepted = true
						}
					}
				}
			}
		}
	}

	Component {
		id: createConf
		FocusScope{
			id: createConfLayout
			objectName: "createConf"
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
						style: ButtonStyle.noBackground
						icon.source: AppIcons.leftArrow
						focus: true
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
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
					SmallButton {
						id: createButton
						text: qsTr("Créer")
						style: ButtonStyle.main
						KeyNavigation.left: backButton
						KeyNavigation.down: meetingSetup
						
						onClicked: {
							if (meetingSetup.conferenceInfoGui.core.subject.length === 0) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La conférence doit contenir un sujet"), false)
							} else if (meetingSetup.conferenceInfoGui.core.duration <= 0) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La fin de la conférence doit être plus récente que son début"), false)
							} else if (meetingSetup.conferenceInfoGui.core.participantCount === 0) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La conférence doit contenir au moins un participant"), false)
							} else {
								meetingSetup.conferenceInfoGui.core.save()
								mainWindow.showLoadingPopup(qsTr("Création de la réunion en cours ..."), true, function () {
									meetingSetup.conferenceInfoGui.core.cancelCreation()
								})
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
							if (meetingSetup.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Ready) {
								leftPanelStackView.pop()
								UtilsCpp.showInformationPopup(qsTr("Nouvelle réunion"), qsTr("Réunion planifiée avec succès"), true)
								mainWindow.closeLoadingPopup()
							}
							else if (meetingSetup.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.AllocationPending
								|| meetingSetup.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Updating) {
								mainWin.showLoadingPopup(qsTr("Création de la réunion en cours..."), true, function () {
									leftPanelStackView.pop()
								})
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
			objectName: "editConf"
			property bool isCreation
			property ConferenceInfoGui conferenceInfoGui
			width: overridenRightPanelStackView.width
			height: editLayout.height
			ColumnLayout {
				id: editLayout
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.topMargin: 58 * DefaultStyle.dp
				spacing: 0
				Section {
					Layout.preferredWidth: 393 * DefaultStyle.dp
					content: RowLayout {
						spacing: 16 * DefaultStyle.dp
						Layout.preferredWidth: overridenRightPanelStackView.width
						Button {
							id: backButton
							icon.source: AppIcons.leftArrow
							icon.width: 24 * DefaultStyle.dp
							icon.height: 24 * DefaultStyle.dp
							style: ButtonStyle.noBackground
							KeyNavigation.left: saveButton
							KeyNavigation.right: titleText
							KeyNavigation.down: conferenceEdit
							KeyNavigation.up: conferenceEdit
							onClicked: {
								conferenceEdit.conferenceInfoGui.core.undo()
								overridenRightPanelStackView.pop()
							}
						}
						RowLayout {
							spacing: 8 * DefaultStyle.dp
							EffectImage{
								imageSource: AppIcons.usersThree
								colorizationColor: DefaultStyle.main2_600
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
							}
							TextInput {
								id: titleText
								Layout.fillWidth: true
								color: DefaultStyle.main2_600
								clip: true
								font {
									pixelSize: 20 * DefaultStyle.dp
									weight: 800 * DefaultStyle.dp
								}
								KeyNavigation.left: backButton
								KeyNavigation.right: saveButton
								KeyNavigation.down: conferenceEdit
								KeyNavigation.up: conferenceEdit
								onActiveFocusChanged: if(activeFocus==true) selectAll()
								onTextEdited: mainItem.selectedConference.core.subject = text
								Component.onCompleted: {
									text = mainItem.selectedConference.core.subject
								}
							}
							SmallButton {
								id: saveButton
								style: ButtonStyle.main
								focus: true
								text: qsTr("Enregistrer")
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
				}
				MeetingForm {
					id: conferenceEdit
					property bool isCreation
					isCreation: editFocusScope.isCreation
					conferenceInfoGui: editFocusScope.conferenceInfoGui
					Layout.fillWidth: true
					Layout.fillHeight: true
					
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
						target: conferenceEdit.conferenceInfoGui.core
						ignoreUnknownSignals: true
						function onSaveFailed() {
							UtilsCpp.getMainWindow().closeLoadingPopup()
						}
						function onSchedulerStateChanged() {
							editFocusScope.enabled = conferenceInfoGui.core.schedulerState != LinphoneEnums.ConferenceSchedulerState.AllocationPending
							if (conferenceEdit.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Ready) {
								overridenRightPanelStackView.pop()
								UtilsCpp.getMainWindow().closeLoadingPopup()
								UtilsCpp.showInformationPopup(qsTr("Enregistré"), qsTr("Réunion modifiée avec succès"), true)
							}
							else if (conferenceEdit.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.AllocationPending
								|| conferenceEdit.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Updating) {
									UtilsCpp.getMainWindow().showLoadingPopup(qsTr("Modification de la réunion en cours..."))
							} else if (conferenceEdit.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Error) {
								UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La modification de la conférence a échoué"), false)
								UtilsCpp.getMainWindow().closeLoadingPopup()
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
						style: ButtonStyle.noBackgroundOrange
						icon.source: AppIcons.leftArrow
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						KeyNavigation.right: addButton
						KeyNavigation.down: addParticipantLayout
						onClicked: container.pop()
					}
					ColumnLayout {
						spacing: 8 * DefaultStyle.dp
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
					SmallButton {
						id: addButton
						enabled: addParticipantLayout.selectedParticipantsCount.length != 0
						Layout.rightMargin: 21 * DefaultStyle.dp
						focus: enabled
						style: ButtonStyle.main
						text: qsTr("Ajouter")
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
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.topMargin: 58 * DefaultStyle.dp
				visible: mainItem.selectedConference
				spacing: 25 * DefaultStyle.dp
				Section {
					visible: mainItem.selectedConference
					Layout.fillWidth: true
					content: RowLayout {
						spacing: 8 * DefaultStyle.dp
						EffectImage {
							imageSource: AppIcons.usersThree
							colorizationColor: DefaultStyle.main2_600
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
						}
						Text {
							Layout.fillWidth: true
							text: mainItem.selectedConference && mainItem.selectedConference.core? mainItem.selectedConference.core.subject : ""
							maximumLineCount: 1
							font {
								pixelSize: 20 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
						Item {
							Layout.fillWidth: true
						}
						RoundButton {
							id: editButton
							property var isMeObj: UtilsCpp.isMe(mainItem.selectedConference?.core?.organizerAddress)
							visible: mainItem.selectedConference && isMeObj && isMeObj.value || false
							icon.source: AppIcons.pencil
							style: ButtonStyle.noBackgroundOrange
							KeyNavigation.left: leftPanelStackView.currentItem
							KeyNavigation.right: deletePopup
							KeyNavigation.up: joinButton
							KeyNavigation.down: shareNetworkButton
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
							
							popup.contentItem: IconLabelButton {
								style: ButtonStyle.hoveredBackgroundRed
								property var isMeObj: UtilsCpp.isMe(mainItem.selectedConference?.core?.organizerAddress)
								property bool canCancel: isMeObj && isMeObj.value && mainItem.selectedConference?.core?.state !== LinphoneEnums.ConferenceInfoState.Cancelled
								icon.source: AppIcons.trashCan
								text: qsTr("Supprimer cette réunion")
								
								onClicked: {
									if (mainItem.selectedConference) {
										cancelAndDeleteConfDialog.cancel = canCancel
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
							EffectImage {
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								colorizationColor: DefaultStyle.main2_600
								imageSource: AppIcons.videoCamera
							}
							SmallButton {
								id: linkButton
								Layout.fillWidth: true
								text: mainItem.selectedConference ? mainItem.selectedConference.core?.uri : ""
								textSize: Typography.p1.pixelSize
								textWeight: Typography.p1.weight
								underline: true
								style: ButtonStyle.noBackground
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
							RoundButton {
								id: shareNetworkButton
								style: ButtonStyle.noBackground
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
							EffectImage {
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								imageSource: AppIcons.clock
								colorizationColor: DefaultStyle.main2_600
							}
							Text {
								text: mainItem.selectedConference && mainItem.selectedConference.core
										? UtilsCpp.toDateString(mainItem.selectedConference.core.dateTime) 
										+ " | " + UtilsCpp.toDateHourString(mainItem.selectedConference.core.dateTime) 
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
							EffectImage {
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								imageSource: AppIcons.globe
								colorizationColor: DefaultStyle.main2_600
							}
							Text {
								text: qsTr("Time zone: ") + (mainItem.selectedConference && mainItem.selectedConference.core ? (mainItem.selectedConference.core.timeZoneModel.displayName + ", " + mainItem.selectedConference.core.timeZoneModel.countryName) : "")
								font {
									pixelSize: 14 * DefaultStyle.dp
									capitalization: Font.Capitalize
								}
							}
						}
					}
				}
				Section {
					visible: mainItem.selectedConference && mainItem.selectedConference.core?.description.length != 0
					content: RowLayout {
						spacing: 8 * DefaultStyle.dp
						EffectImage {
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							imageSource: AppIcons.note
							colorizationColor: DefaultStyle.main2_600
						}
						Text {
							text: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.description : ""
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
							_address: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.organizerAddress : ""
						}
						Text {
							text: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.organizerName : ""
							font {
								pixelSize: 14 * DefaultStyle.dp
								capitalization: Font.Capitalize
							}
						}
					}
				}
				Section {
					visible: participantList.count > 0
					content: RowLayout {
						Layout.preferredHeight: participantList.height
						width: 393 * DefaultStyle.dp
						spacing: 8 * DefaultStyle.dp
						EffectImage {
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							Layout.alignment: Qt.AlignLeft | Qt.AlignTop
							Layout.topMargin: 20 * DefaultStyle.dp
							imageSource: AppIcons.usersTwo
							colorizationColor: DefaultStyle.main2_600
						}
						ListView {
							id: participantList
							Layout.preferredHeight: Math.min(184 * DefaultStyle.dp, contentHeight)
							Layout.fillWidth: true
							model: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.participants : []
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
									property var displayNameObj: UtilsCpp.getDisplayName(modelData.address)
									text: displayNameObj?.value || ""
									maximumLineCount: 1
									Layout.fillWidth: true
									font {
										pixelSize: 14 * DefaultStyle.dp
										capitalization: Font.Capitalize
									}
								}
								Text {
									text: qsTr("Organizer")
									visible: mainItem.selectedConference && mainItem.selectedConference.core?.organizerAddress === modelData.address
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
				BigButton {
					id: joinButton
					visible: mainItem.selectedConference && mainItem.selectedConference.core?.state !== LinphoneEnums.ConferenceInfoState.Cancelled
					Layout.fillWidth: true
					text: qsTr("Rejoindre la réunion")
					focus: true
					KeyNavigation.up: shareNetworkButton
					KeyNavigation.down: deletePopup
					KeyNavigation.left: leftPanelStackView.currentItem
					KeyNavigation.right: leftPanelStackView.currentItem
					onClicked: {
						console.log(mainItem.selectedConference.core.uri)
						var callsWindow = UtilsCpp.getCallsWindow()
						callsWindow.setupConference(mainItem.selectedConference)
						UtilsCpp.smartShowWindow(callsWindow)
					}
				}
				Item { Layout.fillHeight: true}
			}
		}
	}
}
