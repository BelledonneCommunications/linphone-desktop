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
    //: "Créer une réunion"
    noItemButtonText: qsTr("meetings_add")
    //: "Aucune réunion"
    emptyListText: qsTr("meetings_list_empty")
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
        Layout.leftMargin: Math.round(45 * DefaultStyle.dp)
		initialItem: listLayout
		clip: true
	}

	Dialog {
		id: cancelAndDeleteConfDialog
		property bool cancel: false
		signal cancelRequested()
        // width: Math.round(278 * DefaultStyle.dp)
        //: "Souhaitez-vous annuler et supprimer cette réunion ?"
        text: cancel ? qsTr("meeting_schedule_cancel_dialog_message")
                       //: Souhaitez-vous supprimer cette réunion ?
                     : qsTr("meeting_schedule_delete_dialog_message")
		buttons: [
			BigButton {
				visible: cancelAndDeleteConfDialog.cancel
				style: ButtonStyle.main
                //: "Annuler et supprimer"
                text: qsTr("meeting_schedule_cancel_and_delete_action")
				onClicked: {
					cancelAndDeleteConfDialog.cancelRequested()
					cancelAndDeleteConfDialog.accepted()
					cancelAndDeleteConfDialog.close()
				}
			},
			BigButton {
                //: "Supprimer seulement"
                text: cancelAndDeleteConfDialog.cancel ? qsTr("meeting_schedule_delete_only_action")
                                                        //: "Supprimer"
                                                       : qsTr("meeting_schedule_delete_action")
				style: ButtonStyle.main
				onClicked: {
					cancelAndDeleteConfDialog.accepted()
					cancelAndDeleteConfDialog.close()
				}
			},
			BigButton {
                //: Retour
                text: qsTr("back_action")
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
            width: Math.round(393 * DefaultStyle.dp)
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
                    Layout.rightMargin: Math.round(38 * DefaultStyle.dp)
					spacing: 0					
					Text {
						Layout.fillWidth: true
                        //: Réunions
                        text: qsTr("meetings_list_title")
						color: DefaultStyle.main2_700
                        font.pixelSize: Typography.h2.pixelSize
                        font.weight: Typography.h2.weight
					}
					Item{Layout.fillWidth: true}
					Button {
						style: ButtonStyle.noBackground
						icon.source: AppIcons.plusCircle
                        Layout.preferredWidth: Math.round(28 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(28 * DefaultStyle.dp)
                        icon.width: Math.round(28 * DefaultStyle.dp)
                        icon.height: Math.round(28 * DefaultStyle.dp)
						onClicked: {
							mainItem.editConference()
						}
					}
				}
				SearchBar {
					id: searchBar
					Layout.fillWidth: true
                    Layout.topMargin: Math.round(18 * DefaultStyle.dp)
                    Layout.rightMargin: Math.round(38 * DefaultStyle.dp)
                    //: "Rechercher une réunion"
                    placeholderText: qsTr("meetings_search_hint")
					KeyNavigation.up: conferenceList
					KeyNavigation.down: conferenceList
                    visible: conferenceList.count !== 0 || text.length !== 0
					Binding {
						target: mainItem
						property: "showDefaultItem"
						when: searchBar.text.length !== 0
						value: false
					}
				}
				Text {
					visible: conferenceList.count === 0
                    Layout.topMargin: Math.round(137 * DefaultStyle.dp)
					Layout.fillHeight: true
					Layout.alignment: Qt.AlignHCenter
                    //: "Aucun résultat…"
                    text: searchBar.text.length !== 0 ? qsTr("list_filter_no_result_found")
                                                        //: "Aucune réunion"
                                                      : qsTr("meetings_empty_list")
					font {
                        pixelSize: Typography.h4.pixelSize
                        weight: Typography.h4.weight
					}
				}
				MeetingListView {
					id: conferenceList
					// Remove 24 from first section padding because we cannot know that it is the first section. 24 is the margins between sections.
                    Layout.topMargin: Math.round(38 * DefaultStyle.dp) - Math.round(24 * DefaultStyle.dp)
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
                spacing: Math.round(33 * DefaultStyle.dp)
				anchors.fill: parent
				RowLayout {
                    Layout.rightMargin: Math.round(35 * DefaultStyle.dp)
                    spacing: Math.round(5 * DefaultStyle.dp)
					Button {
						id: backButton
						style: ButtonStyle.noBackground
						icon.source: AppIcons.leftArrow
						focus: true
                        icon.width: Math.round(24 * DefaultStyle.dp)
                        icon.height: Math.round(24 * DefaultStyle.dp)
						KeyNavigation.right: createButton
						KeyNavigation.down: meetingSetup
						onClicked: {
							meetingSetup.conferenceInfoGui.core.undo()
							leftPanelStackView.pop()
						}
					}
					Text {
                        //: "Nouvelle réunion"
                        text: qsTr("meeting_schedule_title")
						color: DefaultStyle.main2_700
						font {
                            pixelSize: Typography.h3.pixelSize
                            weight: Typography.h3.weight
						}
						Layout.fillWidth: true
					}
					Item {Layout.fillWidth: true}
					SmallButton {
						id: createButton
                        text: qsTr("create")
						style: ButtonStyle.main
						KeyNavigation.left: backButton
						KeyNavigation.down: meetingSetup
						
						onClicked: {
                            if (meetingSetup.conferenceInfoGui.core.subject.length === 0 || meetingSetup.conferenceInfoGui.core.participantCount === 0) {
                                UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                                              //: Veuillez saisir un titre et sélectionner au moins un participant
                                                              qsTr("meeting_schedule_mandatory_field_not_filled_toast"), false)
							} else if (meetingSetup.conferenceInfoGui.core.duration <= 0) {
                                UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                                              //: "La fin de la conférence doit être plus récente que son début"
                                                              qsTr("meeting_schedule_duration_error_toast"), false)
                            } else {
								meetingSetup.conferenceInfoGui.core.save()
                                //: "Création de la réunion en cours …"
                                mainWindow.showLoadingPopup(qsTr("meeting_schedule_creation_in_progress"), true, function () {
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
                    Layout.rightMargin: Math.round(35 * DefaultStyle.dp)
					Connections {
						target: meetingSetup.conferenceInfoGui ? meetingSetup.conferenceInfoGui.core : null
						function onConferenceSchedulerStateChanged() {
							var mainWin = UtilsCpp.getMainWindow()
							if (meetingSetup.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Ready) {
								leftPanelStackView.pop()
                                //: "Nouvelle réunion"
                                UtilsCpp.showInformationPopup(qsTr("meeting_schedule_title"),
                                                              //: "Réunion planifiée avec succès"
                                                              qsTr("meeting_info_created_toast"), true)
								mainWindow.closeLoadingPopup()
							}
							else if (meetingSetup.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.AllocationPending
								|| meetingSetup.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Updating) {
                                mainWin.showLoadingPopup(qsTr("meeting_schedule_creation_in_progress"), true, function () {
									leftPanelStackView.pop()
								})
							} else {
								if (meetingSetup.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Error) {
                                    UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                                                  //: "Échec de création de la réunion !"
                                                                  qsTr("meeting_failed_to_schedule_toast"), false)
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
                anchors.topMargin: Math.round(58 * DefaultStyle.dp)
				spacing: 0
				Section {
                    Layout.preferredWidth: Math.round(393 * DefaultStyle.dp)
					content: RowLayout {
                        spacing: Math.round(16 * DefaultStyle.dp)
						Layout.preferredWidth: overridenRightPanelStackView.width
						Button {
							id: backButton
							icon.source: AppIcons.leftArrow
                            icon.width: Math.round(24 * DefaultStyle.dp)
                            icon.height: Math.round(24 * DefaultStyle.dp)
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
                            spacing: Math.round(8 * DefaultStyle.dp)
							EffectImage{
								imageSource: AppIcons.usersThree
								colorizationColor: DefaultStyle.main2_600
                                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
							}
							TextInput {
								id: titleText
								Layout.fillWidth: true
								color: DefaultStyle.main2_600
								clip: true
								font {
                                    pixelSize: Math.round(20 * DefaultStyle.dp)
                                    weight: Typography.h4.weight
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
                                text: qsTr("save")
								KeyNavigation.left: titleText
								KeyNavigation.right: backButton
								KeyNavigation.down: conferenceEdit
								KeyNavigation.up: conferenceEdit
								onClicked: {
                                    if (mainItem.selectedConference.core.subject.length === 0 || mainItem.selectedConference.core.participantCount === 0) {
                                        UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                                                      qsTr("meeting_schedule_mandatory_field_not_filled_toast"), false)
									} else if (mainItem.selectedConference.core.duration <= 0) {
                                        UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                                                      qsTr("meeting_schedule_duration_error_toast"), false)
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
                                //: "Enregistré"
                                UtilsCpp.showInformationPopup(qsTr("saved"),
                                                              //: "Réunion mise à jour"
                                                              qsTr("meeting_info_updated_toast"), true)
							}
							else if (conferenceEdit.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.AllocationPending
								|| conferenceEdit.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Updating) {
                                    //: "Modification de la réunion en cours…"
                                    UtilsCpp.getMainWindow().showLoadingPopup(qsTr("meeting_schedule_edit_in_progress"))
							} else if (conferenceEdit.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Error) {
                                UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                                                              //: "Échec de la modification de la réunion !"
                                                              qsTr("meeting_failed_to_edit_toast"), false)
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
            spacing: Math.round(18 * DefaultStyle.dp)
			FocusScope{
				Layout.fillWidth: true
				Layout.preferredHeight: childrenRect.height
				ColumnLayout {
                    spacing: Math.round(4 * DefaultStyle.dp)
					Layout.fillWidth: true
					RowLayout {
						id: addParticipantsButtons
                        spacing: Math.round(10 * DefaultStyle.dp)
						Button {
							id: addParticipantsBackButton
							style: ButtonStyle.noBackgroundOrange
							icon.source: AppIcons.leftArrow
                            icon.width: Math.round(24 * DefaultStyle.dp)
                            icon.height: Math.round(24 * DefaultStyle.dp)
							KeyNavigation.right: addButton
							KeyNavigation.down: addParticipantLayout
							onClicked: container.pop()
						}
						Text {
                            //: "Ajouter des participants"
                            text: qsTr("meeting_schedule_add_participants_title")
							color: DefaultStyle.main1_500_main
							maximumLineCount: 1
							font {
                                pixelSize: Math.round(18 * DefaultStyle.dp)
                                weight: Typography.h4.weight
							}
							Layout.fillWidth: true
						}
						SmallButton {
							id: addButton
							enabled: addParticipantLayout.selectedParticipantsCount.length != 0
                            Layout.leftMargin: Math.round(11 * DefaultStyle.dp)
							focus: enabled
							style: ButtonStyle.main
                            text: qsTr("add")
							KeyNavigation.left: addParticipantsBackButton
							KeyNavigation.down: addParticipantLayout
							onClicked: {
								mainItem.addParticipantsValidated(addParticipantLayout.selectedParticipants)
							}
						}
					}
					Text {
                        //: "%n participant(s) sélectionné(s)"
                        text: qsTr("group_call_participant_selected", '', addParticipantLayout.selectedParticipantsCount).arg(addParticipantLayout.selectedParticipantsCount)
                        color: DefaultStyle.main2_500main
						Layout.leftMargin: addParticipantsBackButton.width + addParticipantsButtons.spacing
						maximumLineCount: 1
						font {
                            pixelSize: Math.round(12 * DefaultStyle.dp)
                            weight: Math.round(300 * DefaultStyle.dp)
						}
						Layout.fillWidth: true
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
                anchors.topMargin: Math.round(58 * DefaultStyle.dp)
				visible: mainItem.selectedConference
                spacing: Math.round(25 * DefaultStyle.dp)
				Section {
					visible: mainItem.selectedConference
					Layout.fillWidth: true
					content: RowLayout {
                        spacing: Math.round(8 * DefaultStyle.dp)
						EffectImage {
							imageSource: AppIcons.usersThree
							colorizationColor: DefaultStyle.main2_600
                            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
						}
						Text {
							Layout.fillWidth: true
							text: mainItem.selectedConference && mainItem.selectedConference.core? mainItem.selectedConference.core.subject : ""
							maximumLineCount: 1
							font {
                                pixelSize: Math.round(20 * DefaultStyle.dp)
                                weight: Typography.h4.weight
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
                            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
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
                                //: "Supprimer la réunion"
                                text: qsTr("meeting_info_delete")
								
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
                        spacing: Math.round(15 * DefaultStyle.dp)
						width: parent.width
						RowLayout {
                            spacing: Math.round(8 * DefaultStyle.dp)
							Layout.fillWidth: true
							EffectImage {
                                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
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
                                    UtilsCpp.showInformationPopup(qsTr("saved"),
                                                                  //: "Adresse de la réunion copiée"
                                                                  qsTr("meeting_address_copied_to_clipboard_toast"))
								}
							}
						}
						RowLayout {
                            spacing: Math.round(8 * DefaultStyle.dp)
							EffectImage {
                                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
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
                                    pixelSize: Math.round(14 * DefaultStyle.dp)
									capitalization: Font.Capitalize
								}
							}
						}
						RowLayout {
                            spacing: Math.round(8 * DefaultStyle.dp)
							EffectImage {
                                Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                                Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
								imageSource: AppIcons.globe
								colorizationColor: DefaultStyle.main2_600
							}
							Text {
                                //: "Fuseau horaire"
                                text: "%1: %2".arg(qsTr("meeting_schedule_timezone_title")).arg(mainItem.selectedConference && mainItem.selectedConference.core ? (mainItem.selectedConference.core.timeZoneModel.displayName + ", " + mainItem.selectedConference.core.timeZoneModel.countryName) : "")
								font {
                                    pixelSize: Math.round(14 * DefaultStyle.dp)
									capitalization: Font.Capitalize
								}
							}
						}
					}
				}
				Section {
					visible: mainItem.selectedConference && mainItem.selectedConference.core?.description.length != 0
					content: RowLayout {
                        spacing: Math.round(8 * DefaultStyle.dp)
						EffectImage {
                            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
							imageSource: AppIcons.note
							colorizationColor: DefaultStyle.main2_600
						}
						Text {
							text: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.description : ""
							Layout.fillWidth: true
							font {
                                pixelSize: Math.round(14 * DefaultStyle.dp)
								capitalization: Font.Capitalize
							}
						}
					}
				}
				Section {
					content: RowLayout {
                        spacing: Math.round(8 * DefaultStyle.dp)
						EffectImage {
                            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
							imageSource: AppIcons.userRectangle
							colorizationColor: DefaultStyle.main2_600
						}
						Avatar {
                            Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
							_address: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.organizerAddress : ""
						}
						Text {
							text: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.organizerName : ""
							font {
                                pixelSize: Math.round(14 * DefaultStyle.dp)
								capitalization: Font.Capitalize
							}
						}
					}
				}
				Section {
					visible: participantList.count > 0
					content: RowLayout {
						Layout.preferredHeight: participantList.height
                        width: Math.round(393 * DefaultStyle.dp)
                        spacing: Math.round(8 * DefaultStyle.dp)
						EffectImage {
                            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
							Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                            Layout.topMargin: Math.round(20 * DefaultStyle.dp)
							imageSource: AppIcons.usersTwo
							colorizationColor: DefaultStyle.main2_600
						}
						ListView {
							id: participantList
                            Layout.preferredHeight: Math.min(Math.round(184 * DefaultStyle.dp), contentHeight)
							Layout.fillWidth: true
							model: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.participants : []
							clip: true
							delegate: RowLayout {
                                height: Math.round(56 * DefaultStyle.dp)
								width: participantList.width
								Avatar {
                                    Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                                    Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
									_address: modelData.address
									shadowEnabled: false
								}
								Text {
									property var displayNameObj: UtilsCpp.getDisplayName(modelData.address)
									text: displayNameObj?.value || ""
									maximumLineCount: 1
									Layout.fillWidth: true
									font {
                                        pixelSize: Math.round(14 * DefaultStyle.dp)
										capitalization: Font.Capitalize
									}
								}
								Text {
                                    //: "Organisateur"
                                    text: qsTr("meeting_info_organizer_label")
									visible: mainItem.selectedConference && mainItem.selectedConference.core?.organizerAddress === modelData.address
									color: DefaultStyle.main2_400
									font {
                                        pixelSize: Math.round(12 * DefaultStyle.dp)
                                        weight: Math.round(300 * DefaultStyle.dp)
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
                    //: "Rejoindre la réunion"
                    text: qsTr("meeting_info_join_title")
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
