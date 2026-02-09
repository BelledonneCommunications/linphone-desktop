import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

// TODO : spacing
AbstractMainPage {
	id: mainItem
	property ConferenceInfoGui selectedConference
	property int meetingListCount: 0
	signal returnRequested()
	signal addParticipantsValidated(list<string> selectedParticipants)
    //: "Créer une réunion"
    noItemButtonText: qsTr("meetings_add")
    //: "Aucune réunion"
    emptyListText: qsTr("meetings_list_empty")
	newItemIconSource: AppIcons.plusCircle
	rightPanelColor: selectedConference ? DefaultStyle.grey_0 : DefaultStyle.grey_100 
	showDefaultItem: leftPanelStackView.currentItem && leftPanelStackView.currentItem.objectName === "listLayout" && meetingListCount === 0

	rightPanelStackView.width:  Utils.getSizeWithScreenRatio(393)
	rightPanelStackTopMargin: Utils.getSizeWithScreenRatio(45)
	rightPanelStackBottomMargin: Utils.getSizeWithScreenRatio(30)

	function createPreFilledMeeting(subject, addresses) {
		mainItem.selectedConference = Qt.createQmlObject('import Linphone
										ConferenceInfoGui{
										}', mainItem)
		mainItem.selectedConference.core.resetParticipants(addresses)
		mainItem.selectedConference.core.subject = subject
		var item = leftPanelStackView.push(createConf, {"conferenceInfoGui": mainItem.selectedConference})
		item.forceActiveFocus()
	}


	function editConference(confInfoGui = null) {
		var isCreation = !confInfoGui
		var item
		if (isCreation) {
			confInfoGui = Qt.createQmlObject('import Linphone
											ConferenceInfoGui{
											}', mainItem)
			mainItem.selectedConference = confInfoGui
			item = leftPanelStackView.push(createConf, {"conferenceInfoGui": mainItem.selectedConference})
			item.forceActiveFocus()
		} else {
			mainItem.selectedConference = confInfoGui
			item = rightPanelStackView.push(editConf, {"conferenceInfoGui": mainItem.selectedConference})
			item.forceActiveFocus()
		}
	}
	
	
	onVisibleChanged: if (!visible) {
		leftPanelStackView.clear()
		leftPanelStackView.push(leftPanelStackView.initialItem)
	}

	onSelectedConferenceChanged: {
		// While a conference is being created or edited, we need to stay on the edition page
		rightPanelStackView.clear()
		if ((rightPanelStackView.currentItem && rightPanelStackView.currentItem.objectName === "editConf")
				|| (leftPanelStackView.currentItem && leftPanelStackView.currentItem.objectName === "createConf")) return
		if (selectedConference && selectedConference.core && selectedConference.core.haveModel) {
			rightPanelStackView.push(meetingDetail, Control.StackView.Immediate)
		}
	}

	onNoItemButtonPressed: editConference()

	Dialog {
		id: cancelAndDeleteConfDialog
		property ConferenceInfoGui confInfoToDelete
		property bool cancel: false
		signal cancelRequested()
        // width: Utils.getSizeWithScreenRatio(278)
        //: "Souhaitez-vous annuler et supprimer cette réunion ?"
        text: cancel ? qsTr("meeting_schedule_cancel_dialog_message")
                       //: Souhaitez-vous supprimer cette réunion ?
                     : qsTr("meeting_schedule_delete_dialog_message")

		onCancelRequested: {
			confInfoToDelete.core.lCancelConferenceInfo()
		}
		onAccepted: {
			confInfoToDelete.core.lDeleteConferenceInfo()
		}
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

	leftPanelContent: Control.StackView {
		id: leftPanelStackView
		Layout.fillWidth: true
		Layout.fillHeight: true
		Layout.leftMargin: Utils.getSizeWithScreenRatio(45)
		initialItem: listLayout
		clip: true
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
			enabled: !rightPanelStackView.currentItem || rightPanelStackView.currentItem.objectName !== "editConf"

			ColumnLayout {
				anchors.fill: parent
				spacing: 0
				RowLayout {
					// direction: FlexboxLayout.Row
					// alignItems: FlexboxLayout.AlignCenter
					spacing: Utils.getSizeWithScreenRatio(16)
					Layout.rightMargin: Utils.getSizeWithScreenRatio(39)
					Layout.alignment: Qt.AlignTop
					Layout.fillHeight: false
					Text {
						Layout.fillWidth: true
						//: Réunions
						text: qsTr("meetings_list_title")
						color: DefaultStyle.main2_700
						font.pixelSize: Typography.h2.pixelSize
						font.weight: Typography.h2.weight
					}
					Button {
						id: newConfButton
						style: ButtonStyle.noBackground
						icon.source: AppIcons.plusCircle
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(28)
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(28)
						icon.width: Utils.getSizeWithScreenRatio(28)
						icon.height: Utils.getSizeWithScreenRatio(28)
						KeyNavigation.down: scrollToCurrentDateButton
						onClicked: {
							mainItem.editConference()
						}
					}
				}
				RowLayout {
					visible: conferenceList.count !== 0 || searchBar.text.length !== 0
					spacing: Utils.getSizeWithScreenRatio(11)
					Layout.topMargin: Utils.getSizeWithScreenRatio(18)
					Layout.rightMargin: Utils.getSizeWithScreenRatio(38)
					KeyNavigation.up: newConfButton
					KeyNavigation.down: searchBar
					Button {
						id: scrollToCurrentDateButton
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(32)
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(32)
						icon.source: AppIcons.calendar
						style: ButtonStyle.noBackground
						onClicked: conferenceList.scrollToCurrentDate()
					}
					SearchBar {
						id: searchBar
						Layout.fillWidth: true
						//: "Rechercher une réunion"
						placeholderText: qsTr("meetings_search_hint")
						KeyNavigation.up: scrollToCurrentDateButton
						KeyNavigation.down: conferenceList
						Binding {
							target: mainItem
							property: "showDefaultItem"
							when: searchBar.text.length !== 0
							value: false
						}
					}
				}
				Text {
					visible: conferenceList.count === 0 && !conferenceList.loading
					Layout.topMargin: Utils.getSizeWithScreenRatio(137)
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
					Layout.topMargin: Utils.getSizeWithScreenRatio(38 - 24)
					Layout.fillWidth: true
					Layout.fillHeight: true
					focusPolicy: Qt.ClickFocus
					focus: true

					searchBarText: searchBar.text

					onCountChanged: {
						mainItem.meetingListCount = count
					}
					Binding {
						target: mainItem
						property: "showDefaultItem"
						when: conferenceList.loading
						value: false
					}
					onSelectedConferenceChanged: {
						mainItem.selectedConference = selectedConference
					}
					onMeetingDeletionRequested: (confInfo, canCancel) => {
						cancelAndDeleteConfDialog.confInfoToDelete = confInfo
						cancelAndDeleteConfDialog.cancel = canCancel
						cancelAndDeleteConfDialog.open()
					}

					Keys.onPressed: (event) => {
						if(event.key == Qt.Key_Escape){
							searchBar.forceActiveFocus()
							event.accepted = true
						}else if(event.key == Qt.Key_Right){
							rightPanelStackView.currentItem.forceActiveFocus()
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
			ColumnLayout {
				spacing: Utils.getSizeWithScreenRatio(33)
				anchors.fill: parent
				RowLayout {
					spacing: Utils.getSizeWithScreenRatio(5)
					Layout.rightMargin: Utils.getSizeWithScreenRatio(35)
					Button {
						id: backButton
						style: ButtonStyle.noBackground
						icon.source: AppIcons.leftArrow
						focus: true
						icon.width: Utils.getSizeWithScreenRatio(24)
						icon.height: Utils.getSizeWithScreenRatio(24)
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
									meetingSetup.conferenceInfoGui.core.lCancelCreation()
								})
							}
						}
					}
				}
				Control.ScrollView {
					Layout.fillHeight: true
					Layout.fillWidth: true
					contentHeight: meetingSetup.height
					Control.ScrollBar.vertical: ScrollBar {
						id: meetingScrollBar
						visible: parent.contentHeight > parent.height
						anchors.top: parent.top
						anchors.bottom: parent.bottom
						anchors.right: parent.right
						anchors.rightMargin: Utils.getSizeWithScreenRatio(8)
					}
					MeetingForm {
						id: meetingSetup
						conferenceInfoGui: createConfLayout.conferenceInfoGui
						isCreation: true
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.rightMargin: Utils.getSizeWithScreenRatio(35)
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
							leftPanelStackView.push(addParticipants, {"conferenceInfoGui": conferenceInfoGui, "container": leftPanelStackView,  "overridenWidth": leftPanelStackView.width})
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
	}

	Component {
		id: editConf
		FocusScope{
			id: editFocusScope
			objectName: "editConf"
			property ConferenceInfoGui conferenceInfoGui
			anchors.horizontalCenter: parent?.horizontalCenter
			width: Utils.getSizeWithScreenRatio(393)
			ColumnLayout {
				id: editLayout
				anchors.top: parent.top
				width: Utils.getSizeWithScreenRatio(393)
				height: childrenRect.height
				anchors.horizontalCenter: parent?.horizontalCenter
				spacing: 0
				Section {
					Layout.alignment: Qt.AlignHCenter
					Layout.fillWidth: true
					content: RowLayout {
						spacing: Utils.getSizeWithScreenRatio(16)
						// Layout.preferredWidth: rightPanelStackView.width
						Button {
							id: backButton
							icon.source: AppIcons.leftArrow
							icon.width: Utils.getSizeWithScreenRatio(24)
							icon.height: Utils.getSizeWithScreenRatio(24)
							style: ButtonStyle.noBackground
							KeyNavigation.left: saveButton
							KeyNavigation.right: titleText
							KeyNavigation.down: conferenceEdit
							KeyNavigation.up: conferenceEdit
							onClicked: {
								conferenceEdit.conferenceInfoGui.core.undo()
								rightPanelStackView.pop()
							}
						}
						RowLayout {
							spacing: Utils.getSizeWithScreenRatio(8)
							EffectImage{
								imageSource: AppIcons.usersThree
								colorizationColor: DefaultStyle.main2_600
								Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
								Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
							}
							TextInput {
								id: titleText
								Layout.fillWidth: true
								color: DefaultStyle.main2_600
								clip: true
								font {
									pixelSize: Utils.getSizeWithScreenRatio(20)
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
					isCreation: false
					Layout.fillWidth: true
					Layout.fillHeight: true
					conferenceInfoGui: editFocusScope.conferenceInfoGui

					onAddParticipantsRequested: {
						rightPanelStackView.push(addParticipants, {"conferenceInfoGui": conferenceInfoGui, "container": rightPanelStackView, "overridenWidth": Utils.getSizeWithScreenRatio(393)})
					}
					Connections {
						target: mainItem
						function onAddParticipantsValidated(selectedParticipants) {
							conferenceEdit.conferenceInfoGui.core.resetParticipants(selectedParticipants)
							rightPanelStackView.pop()
						}
					}
					Connections {
						enabled: conferenceEdit.conferenceInfoGui
						target: conferenceEdit.conferenceInfoGui ? conferenceEdit.conferenceInfoGui.core : null
						ignoreUnknownSignals: true
						function onSaveFailed() {
							UtilsCpp.getMainWindow().closeLoadingPopup()
						}
						function onSchedulerStateChanged() {
							editFocusScope.enabled = conferenceInfoGui.core.schedulerState != LinphoneEnums.ConferenceSchedulerState.AllocationPending
							if (conferenceEdit.conferenceInfoGui.core.schedulerState == LinphoneEnums.ConferenceSchedulerState.Ready) {
								rightPanelStackView.pop()
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
		FocusScope{
			id: addParticipantInItem
			property int overridenWidth
			property Control.StackView container
			property ConferenceInfoGui conferenceInfoGui
			anchors.horizontalCenter: parent?.horizontalCenter
			ColumnLayout {
				id: addParticipantsLayout
				spacing: Utils.getSizeWithScreenRatio(18)
				width: parent.overridenWidth ? parent.overridenWidth : parent.width
				anchors.horizontalCenter: parent?.horizontalCenter
				anchors.rightMargin: Utils.getSizeWithScreenRatio(8)
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				ColumnLayout {
					id: title
					Layout.fillHeight: true
					Layout.fillWidth: false
					Layout.preferredWidth: addParticipantsLayout.width
					Layout.alignment: Qt.AlignHCenter
					spacing: Utils.getSizeWithScreenRatio(4)
					RowLayout {
						id: addParticipantsButtons
						spacing: Utils.getSizeWithScreenRatio(10)
						Button {
							id: addParticipantsBackButton
							style: ButtonStyle.noBackgroundOrange
							icon.source: AppIcons.leftArrow
							icon.width: Utils.getSizeWithScreenRatio(24)
							icon.height: Utils.getSizeWithScreenRatio(24)
							KeyNavigation.right: addButton
							KeyNavigation.down: addParticipantsForm
							onClicked: container.pop()
						}
						Text {
							//: "Ajouter des participants"
							text: qsTr("meeting_schedule_add_participants_title")
							color: DefaultStyle.main1_500_main
							maximumLineCount: 1
							font {
								pixelSize: Utils.getSizeWithScreenRatio(18)
								weight: Typography.h4.weight
							}
							Layout.fillWidth: true
						}
						SmallButton {
							id: addButton
							enabled: addParticipantsForm.selectedParticipantsCount.length != 0
							focus: enabled
							style: ButtonStyle.main
							text: qsTr("meeting_schedule_add_participants_apply")
							KeyNavigation.left: addParticipantsBackButton
							KeyNavigation.down: addParticipantsForm
							onClicked: {
								mainItem.addParticipantsValidated(addParticipantsForm.selectedParticipants)
							}
						}
					}
					Text {
						//: "%n participant(s) sélectionné(s)"
						text: qsTr("group_call_participant_selected", '', addParticipantsForm.selectedParticipantsCount).arg(addParticipantsForm.selectedParticipantsCount)
						color: DefaultStyle.main2_500_main
						Layout.leftMargin: addParticipantsBackButton.width + addParticipantsButtons.spacing
						maximumLineCount: 1
						font {
							pixelSize: Utils.getSizeWithScreenRatio(12)
							weight: Utils.getSizeWithScreenRatio(300)
						}
						Layout.fillWidth: true
					}
				}
				AddParticipantsForm {
					id: addParticipantsForm
					Layout.fillWidth: true
					Layout.fillHeight: true
					conferenceInfoGui: addParticipantInItem.conferenceInfoGui
					participantscSrollBarRightMargin: 0
				}
			}
		}
	}

	Component {
		id: meetingDetail
		FocusScope{
			width: Utils.getSizeWithScreenRatio(393)
			anchors.horizontalCenter: parent?.horizontalCenter
			RowLayout {
				id: meetingDetailsLayout
				visible: mainItem.selectedConference
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.bottomMargin: Utils.getSizeWithScreenRatio(30)
				width: Utils.getSizeWithScreenRatio(393)
				// direction: FlexboxLayout.Column
				// alignContent: FlexboxLayout.AlignSpaceBetween
				spacing: Utils.getSizeWithScreenRatio(16)
				Section {
					visible: mainItem.selectedConference
					Layout.fillWidth: true
					content: RowLayout {
						spacing: Utils.getSizeWithScreenRatio(8)
						EffectImage {
							imageSource: AppIcons.usersThree
							colorizationColor: DefaultStyle.main2_600
							Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
							Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
						}
						Text {
							Layout.fillWidth: true
							text: mainItem.selectedConference && mainItem.selectedConference.core? mainItem.selectedConference.core.subject : ""
							maximumLineCount: 1
							font {
								pixelSize: Utils.getSizeWithScreenRatio(20)
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
							Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
							onClicked: mainItem.editConference(mainItem.selectedConference)
						}
						PopupButton {
							id: deletePopup
							Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
							Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
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
										cancelAndDeleteConfDialog.confInfoToDelete = mainItem.selectedConference
										cancelAndDeleteConfDialog.cancel = canCancel
										cancelAndDeleteConfDialog.open()
										deletePopup.close()
									}
								}
							}
						}
					}
				}
				Section {
					Layout.fillWidth: true
					content: ColumnLayout {
						spacing: Utils.getSizeWithScreenRatio(15)
						width: parent.width
						RowLayout {
							spacing: Utils.getSizeWithScreenRatio(8)
							Layout.fillWidth: true
							EffectImage {
								Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
								Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
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
								KeyNavigation.down: calendarPlusButton
								onClicked: {
									var success = UtilsCpp.copyToClipboard(mainItem.selectedConference.core.uri)
									if (success) UtilsCpp.showInformationPopup(qsTr("saved"),
																  //: "Adresse de la réunion copiée"
																  qsTr("meeting_address_copied_to_clipboard_toast"))
								}
							}
						}
						RowLayout {
							spacing: Utils.getSizeWithScreenRatio(8)
							EffectImage {
								Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
								Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
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
									pixelSize: Utils.getSizeWithScreenRatio(14)
									capitalization: Font.Capitalize
								}
							}
							RoundButton {
								id: calendarPlusButton
								style: ButtonStyle.noBackground
								icon.source: AppIcons.calendarPlus
								KeyNavigation.left: calendarPlusButton
								KeyNavigation.right: calendarPlusButton
								KeyNavigation.up: shareNetworkButton
								KeyNavigation.down: joinButton
								onClicked: {
									mainItem.selectedConference.core.exportConferenceToICS()
								}
							}
						}
						RowLayout {
							spacing: Utils.getSizeWithScreenRatio(8)
							EffectImage {
								Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
								Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
								imageSource: AppIcons.globe
								colorizationColor: DefaultStyle.main2_600
							}
							Text {
								Layout.fillWidth: true
								//: "Fuseau horaire"
								text: "%1: %2".arg(qsTr("meeting_schedule_timezone_title")).arg(mainItem.selectedConference && mainItem.selectedConference.core ? (mainItem.selectedConference.core.timeZoneModel.displayName + ", " + mainItem.selectedConference.core.timeZoneModel.countryName) : "")
								font {
									pixelSize: Utils.getSizeWithScreenRatio(14)
									capitalization: Font.Capitalize
								}
							}
						}
					}
				}
				Section {
					Layout.fillWidth: true
					visible: mainItem.selectedConference && mainItem.selectedConference.core?.description.length != 0
					content: RowLayout {
						spacing: Utils.getSizeWithScreenRatio(8)
						EffectImage {
							Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
							Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
							imageSource: AppIcons.note
							colorizationColor: DefaultStyle.main2_600
						}
						Text {
							text: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.description : ""
							Layout.fillWidth: true
							font {
								pixelSize: Utils.getSizeWithScreenRatio(14)
							}
						}
					}
				}
				Section {
					Layout.fillWidth: true
					content: RowLayout {
						spacing: Utils.getSizeWithScreenRatio(8)
						EffectImage {
							Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
							Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
							imageSource: AppIcons.userRectangle
							colorizationColor: DefaultStyle.main2_600
						}
						Avatar {
							Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
							Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
							_address: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.organizerAddress : ""
							secured: friendSecurityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
						}
						Text {
							text: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.organizerName : ""
							font {
								pixelSize: Utils.getSizeWithScreenRatio(14)
								capitalization: Font.Capitalize
							}
						}
					}
				}
				Section {
					visible: participantList.count > 0
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.maximumHeight: participantList.contentHeight + Utils.getSizeWithScreenRatio(1) + spacing
					content: RowLayout {
						width: Utils.getSizeWithScreenRatio(393)
						spacing: Utils.getSizeWithScreenRatio(8)
						EffectImage {
							Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
							Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
							Layout.alignment: Qt.AlignLeft | Qt.AlignTop
							Layout.topMargin: Utils.getSizeWithScreenRatio(20)
							imageSource: AppIcons.usersTwo
							colorizationColor: DefaultStyle.main2_600
						}
						ListView {
							id: participantList
							// Layout.preferredHeight: contentHeight
							Layout.fillWidth: true
							Layout.fillHeight: true
							model: mainItem.selectedConference && mainItem.selectedConference.core ? mainItem.selectedConference.core.participants : []
							clip: true
							Control.ScrollBar.vertical: ScrollBar {
								id: participantScrollBar
								anchors.right: participantList.right
								anchors.top: participantList.top
								anchors.bottom: participantList.bottom
								visible: participantList.height < participantList.contentHeight
							}
							delegate: RowLayout {
								height: Utils.getSizeWithScreenRatio(56)
								width: participantList.width - participantScrollBar.width - Utils.getSizeWithScreenRatio(5)
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
									maximumLineCount: 1
									Layout.fillWidth: true
									font {
										pixelSize: Utils.getSizeWithScreenRatio(14)
										capitalization: Font.Capitalize
									}
								}
								Text {
									//: "Organisateur"
									text: qsTr("meeting_info_organizer_label")
									visible: mainItem.selectedConference && mainItem.selectedConference.core?.organizerAddress === modelData.address
									color: DefaultStyle.main2_400
									font {
										pixelSize: Utils.getSizeWithScreenRatio(12)
										weight: Utils.getSizeWithScreenRatio(300)
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
						var callsWindow = UtilsCpp.getOrCreateCallsWindow()
						callsWindow.setupConference(mainItem.selectedConference)
						UtilsCpp.smartShowWindow(callsWindow)
					}
				}
			}
		}
	}

}
