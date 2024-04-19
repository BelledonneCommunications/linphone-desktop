import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as Control
import Linphone
import EnumsToStringCpp 1.0
import UtilsCpp 1.0
import SettingsCpp 1.0

Window {
	id: mainWindow
	width: 1512 * DefaultStyle.dp
	height: 982 * DefaultStyle.dp
	flags: Qt.Window
	// modality: Qt.WindowModal

	property CallGui call
	property ConferenceInfoGui conferenceInfo

	property ConferenceGui conference: call && call.core.conference || null

	property int conferenceLayout: call && call.core.conferenceVideoLayout || 0

	property bool callTerminatedByUser: false
	
	onCallChanged: {
		// if conference, the main item is only
		// displayed when state is connected
		if (call && middleItemStackView.currentItem != inCallItem
			&& (!conferenceInfo || conference) )
			middleItemStackView.replace(inCallItem)
	}

	function joinConference(options) {
		if (!conferenceInfo || conferenceInfo.core.uri.length === 0) UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La conférence n'a pas pu démarrer en raison d'une erreur d'uri."), mainWindow)
		else {
			UtilsCpp.createCall(conferenceInfo.core.uri, options)
		}
	}

	Component {
		id: popupComp
		InformationPopup{}
	}

	function showInformationPopup(title, description, isSuccess) {
		var infoPopup = popupComp.createObject(popupLayout, {"title": title, "description": description, "isSuccess": isSuccess})
		infoPopup.index = popupLayout.popupList.length
		popupLayout.popupList.push(infoPopup)
		infoPopup.open()
	}

	ColumnLayout {
		id: popupLayout
		anchors.fill: parent
		Layout.alignment: Qt.AlignBottom
		property int nextY: mainWindow.height
		property list<Popup> popupList
		property int popupCount: popupList.length
		spacing: 15 * DefaultStyle.dp
		onPopupCountChanged: {
			nextY = mainWindow.height
			for(var i = 0; i < popupCount; ++i) {
				popupList[i].y = nextY - popupList[i].height
				nextY = nextY - popupList[i].height - 15 * DefaultStyle.dp
			}
		}
	}

	function changeLayout(layoutIndex) {
		if (layoutIndex == 0) {
			console.log("Set Grid layout")
			call.core.lSetConferenceVideoLayout(LinphoneEnums.ConferenceLayout.Grid)
		} else if (layoutIndex == 1) {
			console.log("Set AS layout")
			call.core.lSetConferenceVideoLayout(LinphoneEnums.ConferenceLayout.ActiveSpeaker)
		} else {
			console.log("Set audio-only layout")
			call.core.lSetConferenceVideoLayout(LinphoneEnums.ConferenceLayout.AudioOnly)
		}
	}

	Connections {
		enabled: !!call
		target: call && call.core
		onRemoteVideoEnabledChanged: console.log("remote video enabled", call.core.remoteVideoEnabled)
		onSecurityUpdated: {
			if (call.core.isSecured) {
				zrtpValidation.close()
			}
			else if(call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp) {
				zrtpValidation.open()
				// mainWindow.attachVirtualWindow(Utils.buildLinphoneDialogUri('ZrtpTokenAuthenticationDialog'), {call:callModel})
			}
		}
	}

	property var callState: call && call.core.state
	onCallStateChanged: {
		if (callState === LinphoneEnums.CallState.Connected) {
			if (conferenceInfo && middleItemStackView.currentItem != inCallItem) {
				middleItemStackView.replace(inCallItem)
				bottomButtonsLayout.visible = true
			}
			if(!call.core.isSecured && call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp) {
				zrtpValidation.open()
			}
		}
		else if (callState === LinphoneEnums.CallState.Error || callState === LinphoneEnums.CallState.End) {
			callEnded(call)
		}
	}
	property var transferState: call && call.core.transferState
	onTransferStateChanged: {
		console.log("Transfer state:", transferState)
		if (transferState === LinphoneEnums.CallState.Error) {
			transferErrorPopup.visible = true

		}
		else if (transferState === LinphoneEnums.CallState.Connected){
			var mainWin = UtilsCpp.getMainWindow()
			UtilsCpp.smartShowWindow(mainWin)
			mainWin.transferCallSucceed()
		}
	}
	onClosing: (close) => {
		if (callsModel.haveCall) {
			close.accepted = false
			terminateAllCallsDialog.open()
		}
	}

	Timer {
		id: autoCloseWindow
		interval: 2000
		onTriggered: {
			UtilsCpp.closeCallsWindow()
		} 
	}
	
	function endCall(callToFinish) {
		if (callToFinish) callToFinish.core.lTerminate()
	}
	function callEnded(){
		if (!callsModel.haveCall) {
			bottomButtonsLayout.setButtonsEnabled(false)
			autoCloseWindow.restart()
		} else {
			mainWindow.call = callsModel.currentCall
		}
	}

	Dialog {
		id: terminateAllCallsDialog
		onAccepted: call.core.lTerminateAllCalls()
		width: 278 * DefaultStyle.dp
		text: qsTr("La fenêtre est sur le point d'être fermée. Cela terminera tous les appels en cours. Souhaitez vous continuer ?")
	}

	CallProxy{
		id: callsModel
		onCurrentCallChanged: {
			if(currentCall) {
				mainWindow.call = currentCall
			}
		}
		onHaveCallChanged: {
			if (!haveCall) {
				mainWindow.endCall()
			}
		}
	}

	component BottomButton : Button {
		id: bottomButton
		required property string enabledIcon
		property string disabledIcon
		enabled: call != undefined
		leftPadding: 0
		rightPadding: 0
		topPadding: 0
		bottomPadding: 0
		checkable: true
		background: Rectangle {
			anchors.fill: parent
			color: bottomButton.enabled
					? disabledIcon
						? DefaultStyle.grey_500
						: bottomButton.pressed || bottomButton.checked
							? DefaultStyle.main2_400
							: DefaultStyle.grey_500
					: DefaultStyle.grey_600
			radius: 71 * DefaultStyle.dp
		}
		icon.source: disabledIcon && bottomButton.checked ? disabledIcon : enabledIcon
		icon.width: 32 * DefaultStyle.dp
		icon.height: 32 * DefaultStyle.dp
		contentImageColor: DefaultStyle.grey_0
	}
	ZrtpTokenAuthenticationDialog {
		id: zrtpValidation
		call: mainWindow.call
	}
	Popup {
		id: waitingPopup
		visible: mainWindow.transferState === LinphoneEnums.CallState.OutgoingInit
					|| mainWindow.transferState === LinphoneEnums.CallState.OutgoingProgress
					|| mainWindow.transferState === LinphoneEnums.CallState.OutgoingRinging || false
		modal: true
		closePolicy: Control.Popup.NoAutoClose
		anchors.centerIn: parent
		padding: 20 * DefaultStyle.dp
		underlineColor: DefaultStyle.main1_500_main
		radius: 15 * DefaultStyle.dp
		contentItem: ColumnLayout {
			spacing: 0
			BusyIndicator{
				Layout.alignment: Qt.AlignHCenter
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				text: qsTr("Transfert en cours, veuillez patienter")
			}
		}
	}
	Timer {
		id: autoClosePopup
		interval: 2000
		onTriggered: {
			transferErrorPopup.close()
		} 
	}
	Popup {
		id: transferErrorPopup
		onVisibleChanged: if (visible) autoClosePopup.restart()
		closePolicy: Control.Popup.NoAutoClose
		x : parent.x + parent.width - width
		y : parent.y + parent.height - height
		rightMargin: 20 * DefaultStyle.dp
		bottomMargin: 20 * DefaultStyle.dp
		padding: 20 * DefaultStyle.dp
		underlineColor: DefaultStyle.danger_500main
		radius: 0
		contentItem: ColumnLayout {
			spacing: 0
			Text {
				text: qsTr("Erreur de transfert")
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				text: qsTr("Le transfert d'appel a échoué.")
			}
		}
	}
	
	Rectangle {
		anchors.fill: parent
		color: DefaultStyle.grey_900
		ColumnLayout {
			anchors.fill: parent
			spacing: 10 * DefaultStyle.dp
			anchors.bottomMargin: 10 * DefaultStyle.dp
			anchors.topMargin: 10 * DefaultStyle.dp
			Item {
				Layout.margins: 10 * DefaultStyle.dp
				Layout.fillWidth: true
				Layout.minimumHeight: 25 * DefaultStyle.dp
				RowLayout {
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					spacing: 10 * DefaultStyle.dp
					EffectImage {
						id: callStatusIcon
						Layout.preferredWidth: 30 * DefaultStyle.dp
						Layout.preferredHeight: 30 * DefaultStyle.dp
						// TODO : change with broadcast or meeting icon when available
						// + 
						imageSource: !mainWindow.call
							? AppIcons.meeting
							: (mainWindow.callState === LinphoneEnums.CallState.End
								|| mainWindow.callState === LinphoneEnums.CallState.Released)
								? AppIcons.endCall
								: (mainWindow.callState === LinphoneEnums.CallState.Paused
								|| mainWindow.callState === LinphoneEnums.CallState.PausedByRemote)
									? AppIcons.pause
									: mainWindow.conferenceInfo
										? AppIcons.usersThree
										: mainWindow.call.core.dir === LinphoneEnums.CallDir.Outgoing
											? AppIcons.arrowUpRight
											: AppIcons.arrowDownLeft
						colorizationColor: !mainWindow.call || mainWindow.callState === LinphoneEnums.CallState.Paused
							|| mainWindow.callState === LinphoneEnums.CallState.PausedByRemote || mainWindow.callState === LinphoneEnums.CallState.End
							|| mainWindow.callState === LinphoneEnums.CallState.Released || mainWindow.conferenceInfo 
							? DefaultStyle.danger_500main
							: mainWindow.call.core.dir === LinphoneEnums.CallDir.Outgoing
								? DefaultStyle.info_500_main
								: DefaultStyle.success_500main
					}
					Text {
						id: callStatusText
						text: (mainWindow.callState === LinphoneEnums.CallState.End  || mainWindow.callState === LinphoneEnums.CallState.Released)
							? qsTr("End of the call")
							: (mainWindow.callState === LinphoneEnums.CallState.Paused
							|| mainWindow.callState === LinphoneEnums.CallState.PausedByRemote)
								? qsTr("Appel mis en pause")
								: mainWindow.conferenceInfo
									? mainWindow.conferenceInfo.core.subject
									: mainWindow.call
										? EnumsToStringCpp.dirToString(mainWindow.call.core.dir) + qsTr(" call")
										: ""
						color: DefaultStyle.grey_0
						font {
							pixelSize: 22 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
					}
					Rectangle {
						visible: mainWindow.call && (mainWindow.callState === LinphoneEnums.CallState.Connected
								|| mainWindow.callState === LinphoneEnums.CallState.StreamsRunning)
						Layout.preferredHeight: parent.height
						Layout.preferredWidth: 2 * DefaultStyle.dp
					}
					Text {
						text: mainWindow.call ? UtilsCpp.formatElapsedTime(mainWindow.call.core.duration) : ""
						color: DefaultStyle.grey_0
						font {
							pixelSize: 22 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
						visible: mainWindow.callState === LinphoneEnums.CallState.Connected
								|| mainWindow.callState === LinphoneEnums.CallState.StreamsRunning
					}
					Text {
						text: mainWindow.conferenceInfo ? mainWindow.conferenceInfo.core.getStartEndDateString() : ""
						color: DefaultStyle.grey_0
						font {
							pixelSize: 14 * DefaultStyle.dp
							weight: 400 * DefaultStyle.dp
						}
					}
					Item {
						Layout.fillWidth: true
					}
					RowLayout {
						visible: mainWindow.call && (mainWindow.call.core.recording || mainWindow.call.core.remoteRecording)
						spacing: 0
						Text {
							color: DefaultStyle.danger_500main
							font.pixelSize: 14 * DefaultStyle.dp
							text: mainWindow.call 
								? mainWindow.call.core.recording 
									? qsTr("Vous enregistrez l'appel") 
									: qsTr("Votre correspondant enregistre l'appel")
								: ""
						}
						EffectImage {
							imageSource: AppIcons.recordFill
							colorizationColor: DefaultStyle.danger_500main
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
						}
					}
				}

				Control.Control {
					visible: mainWindow.call && mainWindow.call.core.isSecured
					anchors.centerIn: parent
					topPadding: 8 * DefaultStyle.dp
					bottomPadding: 8 * DefaultStyle.dp
					leftPadding: 10 * DefaultStyle.dp
					rightPadding: 10 * DefaultStyle.dp
					width: 269 * DefaultStyle.dp
					background: Rectangle {
						anchors.fill: parent
						border.color: DefaultStyle.info_500_main
						radius: 15 * DefaultStyle.dp
					}
					contentItem: RowLayout {
						spacing: 0
						Image {
							source: AppIcons.trusted
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							sourceSize.width: 24 * DefaultStyle.dp
							sourceSize.height: 24 * DefaultStyle.dp
							fillMode: Image.PreserveAspectFit
						}
						Text {
							text: "This call is completely secured"
							color: DefaultStyle.info_500_main
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 400 * DefaultStyle.dp
							}
						}
					}
				}
			}
			RowLayout {
				Layout.fillWidth: true
				Layout.fillHeight: true
				spacing: 0
				Control.StackView {
					id: middleItemStackView
					initialItem: mainWindow.call ? inCallItem : waitingRoom
					Layout.fillWidth: true
					Layout.fillHeight: true
					
				}
				OngoingCallRightPanel {
					id: rightPanel
					Layout.fillHeight: true
					Layout.preferredWidth: 393 * DefaultStyle.dp
					Layout.topMargin: 10 * DefaultStyle.dp
					Layout.rightMargin: 20 * DefaultStyle.dp	// !! Design model is inconsistent
					property int currentIndex: 0
					visible: false
					function replace(id) {
						rightPanel.customHeaderButtons = null
						contentStackView.replace(id, Control.StackView.Immediate)
					}
					headerStack.currentIndex: 0
					contentStackView.initialItem: callsListPanel
					headerValidateButtonText: qsTr("Ajouter")
				}
				Component {
					id: contactsListPanel
					CallContactsLists {
						Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Transfert d'appel")
						groupCallVisible: false
						searchBarColor: DefaultStyle.grey_0
						searchBarBorderColor: DefaultStyle.grey_200
						onCallButtonPressed: (address) => {
							mainWindow.call.core.lTransferCall(address)
						}
					}
				}
				Component {
					id: dialerPanel
					ColumnLayout {
						Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Dialer")
						spacing: 0
						Item {
							Layout.fillWidth: true
							Layout.fillHeight: true
						}
						SearchBar {
							id: dialerTextInput
							Layout.fillWidth: true
							Layout.leftMargin: 10 * DefaultStyle.dp
							Layout.rightMargin: 10 * DefaultStyle.dp
							magnifierVisible: false
							color: DefaultStyle.grey_0
							borderColor: DefaultStyle.grey_200
							placeholderText: ""
							numericPad: numPad
							numericPadButton.visible: false
						}
						Item {
							Layout.fillWidth: true
							Layout.preferredHeight: numPad.height
							Layout.topMargin: 10 * DefaultStyle.dp
							NumericPad {
								id: numPad
								width: parent.width
								visible: parent.visible
								closeButtonVisible: false
								onLaunchCall: {
									UtilsCpp.createCall(dialerTextInput.text + "@sip.linphone.org")
								}
							}
						}
					}
				}
				Component {
					id: changeLayoutPanel
					ColumnLayout {
						Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Modifier la disposition")
						spacing: 12 * DefaultStyle.dp
						Text {
							Layout.fillWidth: true
							text: qsTr("La disposition choisie sera enregistrée pour vos prochaines réunions")
							font.pixelSize: 14 * DefaultStyle.dp
							color: DefaultStyle.main2_500main
						}
						RoundedBackgroundControl {
							Layout.fillWidth: true
							contentItem: ColumnLayout {
								spacing: 0
								Repeater {
									model: [
										{text: qsTr("Mosaïque"), imgUrl: AppIcons.squaresFour},
										{text: qsTr("Intervenant actif"), imgUrl: AppIcons.pip},
										{text: qsTr("Audio seulement"), imgUrl: AppIcons.waveform}
									]
									RadioButton {
										id: radiobutton
										checkOnClick: false
										color: DefaultStyle.main1_500_main
										indicatorSize: 20 * DefaultStyle.dp
										leftPadding: indicator.width + spacing
										spacing: 8 * DefaultStyle.dp
										checkable: false	// Qt Documentation is wrong: It is true by default. We don't want to change the checked state if the layout change is not effective.
										checked: index == 0
													? mainWindow.conferenceLayout === LinphoneEnums.ConferenceLayout.Grid
													: index == 1
														? mainWindow.conferenceLayout === LinphoneEnums.ConferenceLayout.ActiveSpeaker
														: mainWindow.conferenceLayout === LinphoneEnums.ConferenceLayout.AudioOnly
										onClicked: mainWindow.changeLayout(index)

										contentItem: RowLayout {
											spacing: 5 * DefaultStyle.dp
											EffectImage {
												id: radioButtonImg
												Layout.preferredWidth: 32 * DefaultStyle.dp
												Layout.preferredHeight: 32 * DefaultStyle.dp
												imageSource: modelData.imgUrl
												colorizationColor: DefaultStyle.main2_500main
											}
											Text {
												text: modelData.text
												color: DefaultStyle.main2_500main
												verticalAlignment: Text.AlignVCenter
												font.pixelSize: 14 * DefaultStyle.dp
												Layout.fillWidth: true
											}
										}
									}
								}
							}
						}
						Item {Layout.fillHeight: true}
					}
				}
				Component {
					id: callsListPanel
					ColumnLayout {
						Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Liste d'appel")
						spacing: 0
						RoundedBackgroundControl {
							Layout.fillWidth: true
							Layout.maximumHeight: rightPanel.height
							visible: callList.contentHeight > 0
							
							contentItem: ListView {
								id: callList
								model: callsModel
								implicitHeight: contentHeight// Math.min(contentHeight, rightPanel.height)
								spacing: 15 * DefaultStyle.dp
								clip: true
								onCountChanged: forceLayout()

								delegate: Item {
									id: callDelegate
									width: callList.width
									height: 45 * DefaultStyle.dp

									RowLayout {
										id: delegateContent
										anchors.fill: parent
										anchors.leftMargin: 10 * DefaultStyle.dp
										anchors.rightMargin: 10 * DefaultStyle.dp
										spacing: 0
										Avatar {
											id: delegateAvatar
											address: modelData.core.peerAddress
											Layout.preferredWidth: 45 * DefaultStyle.dp
											Layout.preferredHeight: 45 * DefaultStyle.dp
										}
										Text {
											id: delegateName
											property var remoteAddress: UtilsCpp.getDisplayName(modelData.core.peerAddress)
											text: remoteAddress ? remoteAddress.value : ""
											Connections {
												target: modelData.core
											}
										}
										Item {
											Layout.fillHeight: true
											Layout.fillWidth: true
										}
										Text {
											id: callStateText
											text: modelData.core.state === LinphoneEnums.CallState.Paused 
											|| modelData.core.state === LinphoneEnums.CallState.PausedByRemote
												? qsTr("Appel en pause") : qsTr("Appel en cours")
										}
										PopupButton {
											id: listCallOptionsButton
											Layout.preferredWidth: 24 * DefaultStyle.dp
											Layout.preferredHeight: 24 * DefaultStyle.dp
											Layout.alignment: Qt.AlignRight

											popup.contentItem: ColumnLayout {
												spacing: 0
												Button {
													background: Item {}
													contentItem: RowLayout {
														spacing: 0
														Image {
															source: modelData.core.state === LinphoneEnums.CallState.Paused 
															|| modelData.core.state === LinphoneEnums.CallState.PausedByRemote
															? AppIcons.phone : AppIcons.pause
															sourceSize.width: 32 * DefaultStyle.dp
															sourceSize.height: 32 * DefaultStyle.dp
															Layout.preferredWidth: 32 * DefaultStyle.dp
															Layout.preferredHeight: 32 * DefaultStyle.dp
															fillMode: Image.PreserveAspectFit
														}
														Text {
															text: modelData.core.state === LinphoneEnums.CallState.Paused 
															|| modelData.core.state === LinphoneEnums.CallState.PausedByRemote
															? qsTr("Reprendre l'appel") : qsTr("Mettre en pause")
															color: DefaultStyle.main2_500main
															Layout.preferredWidth: metrics.width
														}
														TextMetrics {
															id: metrics
															text: qsTr("Reprendre l'appel")
														}
														Item {
															Layout.fillWidth: true
														}
													}
													onClicked: modelData.core.lSetPaused(!modelData.core.paused)
												}
												Button {
													background: Item {}
													contentItem: RowLayout {
														spacing: 0
														EffectImage {
															imageSource: AppIcons.endCall
															colorizationColor: DefaultStyle.danger_500main
															width: 32 * DefaultStyle.dp
															height: 32 * DefaultStyle.dp
														}
														Text {
															color: DefaultStyle.danger_500main
															text: qsTr("Terminer l'appel")
														}
														Item {
															Layout.fillWidth: true
														}
													}
													onClicked: mainWindow.endCall(modelData)
												}
											}
										}
									}
								}
							}
						}
						Item {
							Layout.fillHeight: true
						}
					}
				}
				Component {
					id: settingsPanel
					InCallSettingsPanel {
						Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Paramètres")
						call: mainWindow.call
					}
				}
				Component {
					id: screencastPanel
					ScreencastPanel {
						call: mainwindow.call
						Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Partage de votre écran")
					}
				}
				Component {
					id: participantListPanel
					Control.StackView {
						id: participantsStack
						initialItem: participantListComp
						// Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Participants (%1)").arg(participantList.count)
						onCurrentItemChanged: rightPanel.headerStack.currentIndex = currentItem.Control.StackView.index
						property list<string> selectedParticipants
						signal participantAdded()

						Connections {
							target: rightPanel
							onReturnRequested: participantsStack.pop()
						}

						Component {
							id: participantListComp
							ParticipantListView {
								id: participantList
								Component {
									id: headerbutton
									PopupButton {
										popup.contentItem: Button {
											background: Item{}
											contentItem: RowLayout {
												spacing: 0
												EffectImage {
													colorizationColor: DefaultStyle.main2_600
													imageSource: AppIcons.shareNetwork
													Layout.preferredWidth: 24 * DefaultStyle.dp
													Layout.preferredHeight: 24 * DefaultStyle.dp
												}
												Text {
													text: qsTr("Partager le lien de la réunion")
													font.pixelSize: 14 * DefaultStyle.dp
												}
											}
											onClicked: {
												UtilsCpp.copyToClipboard(mainWindow.conference.core.uri)
												UtilsCpp.showInformationPopup(qsTr("Copié"), qsTr("Le lien de la réunion a été copié dans le presse-papier"), true, mainWindow)
											}
										}
									}
								}
								Control.StackView.onActivated: {
									rightPanel.customHeaderButtons = headerbutton.createObject(rightPanel)
								}
								call: mainWindow.call
								onAddParticipantRequested: participantsStack.push(addParticipantComp)
								onCountChanged: if (participantsStack.Control.StackView.status === Control.StackView.Active && participantsStack.currentItem == participantList) {
									rightPanel.headerTitleText = qsTr("Participants (%1)").arg(count)
								}
								Connections {
									target: participantsStack
									onCurrentItemChanged: {
										console.log("changing title", participantsStack.currentItem == participantList)
										if (participantsStack.currentItem == participantList) rightPanel.headerTitleText = qsTr("Participants (%1)").arg(participantList.count)
									}
								}
								Connections {
									target: rightPanel
									// TODO : chercher comment relier ces infos pour faire le add des participants
									onValidateRequested: {
										participantList.model.addAddresses(participantsStack.selectedParticipants)
										participantsStack.pop()
										participantsStack.participantAdded()
									}
								}
							}
						}
						Component {
							id: addParticipantComp
							AddParticipantsLayout {
								id: addParticipantLayout
								onSelectedParticipantsCountChanged: {
									if (participantsStack.Control.StackView.status === Control.StackView.Active && Control.StackView.visible) {
										rightPanel.headerSubtitleText = qsTr("%1 participant%2 sélectionné").arg(selectedParticipants.length).arg(selectedParticipants.length > 1 ? "s" : "")
									}
									participantsStack.selectedParticipants = selectedParticipants
								}
								Connections {
									target: participantsStack
									onCurrentItemChanged: {
										if (participantsStack.currentItem == addParticipantLayout) {
											rightPanel.headerTitleText = qsTr("Ajouter des participants")
											rightPanel.headerSubtitleText = qsTr("%1 participant%2 sélectionné%2").arg(addParticipantLayout.selectedParticipants.length).arg(addParticipantLayout.selectedParticipants.length > 1 ? "s" : "")
										}
									}
									onParticipantAdded: {
										addParticipantLayout.clearSelectedParticipants()
									}
									onValidateRequested: {
										conferenceInfoGui.core.resetParticipants(contactList.selectedContacts)
										returnRequested()
									}
								}
							}
						}
					}
				}
			}
			Component {
				id: waitingRoom
				WaitingRoom {
					id: waitingRoomIn
					Layout.alignment: Qt.AlignCenter					
					conferenceInfo: mainWindow.conferenceInfo
					onSettingsButtonCheckedChanged: {
						if (settingsButtonChecked) {
							rightPanel.visible = true
							rightPanel.replace(settingsPanel)
						} else {
							rightPanel.visible = false
						}
					}
					Connections {
						target: rightPanel
						onVisibleChanged: if (!visible) waitingRoomIn.settingsButtonChecked = false
					}
					onJoinConfRequested: mainWindow.joinConference({'microEnabled':microEnabled, 'localVideoEnabled':localVideoEnabled})
				}
			}
			Component {
				id: inCallItem
				Item {
					CallLayout{
						anchors.fill: parent
						anchors.leftMargin: 20 * DefaultStyle.dp
						anchors.rightMargin: (rightPanel.visible ? 0 : 10) * DefaultStyle.dp	// Grid and AS have 10 in right margin (so apply -10 here)
						anchors.topMargin: 10 * DefaultStyle.dp
						call: mainWindow.call
						callTerminatedByUser: mainWindow.callTerminatedByUser
					}
				}
			}
			RowLayout {
				id: bottomButtonsLayout
				Layout.alignment: Qt.AlignHCenter
				spacing: 58 * DefaultStyle.dp
				visible: mainWindow.call && !mainWindow.conferenceInfo

				function refreshLayout() {
					if (mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning) {
						connectedCallButtons.visible = bottomButtonsLayout.visible
						moreOptionsButton.visible = bottomButtonsLayout.visible
						bottomButtonsLayout.layoutDirection = Qt.RightToLeft
					}
					else if (mainWindow.callState === LinphoneEnums.CallState.OutgoingInit) {
						connectedCallButtons.visible = false
						bottomButtonsLayout.layoutDirection = Qt.LeftToRight
						moreOptionsButton.visible = false
					}
				}

				Connections {
					target: mainWindow
					onCallStateChanged: bottomButtonsLayout.refreshLayout()
					onCallChanged: bottomButtonsLayout.refreshLayout()
				}
				function setButtonsEnabled(enabled) {
					for(var i=0; i < children.length; ++i) {
						children[i].enabled = false
					}
				}
				Button {
					Layout.row: 0
					icon.source: AppIcons.endCall
					icon.width: 32 * DefaultStyle.dp
					icon.height: 32 * DefaultStyle.dp
					Layout.preferredWidth: 75 * DefaultStyle.dp
					Layout.preferredHeight: 55 * DefaultStyle.dp
					contentImageColor: DefaultStyle.grey_0
					checkable: false
					Layout.column: mainWindow.callState == LinphoneEnums.CallState.OutgoingInit
										|| mainWindow.callState == LinphoneEnums.CallState.OutgoingProgress
										|| mainWindow.callState == LinphoneEnums.CallState.OutgoingRinging
										|| mainWindow.callState == LinphoneEnums.CallState.OutgoingEarlyMedia
										|| mainWindow.callState == LinphoneEnums.CallState.IncomingReceived
										? 0 : bottomButtonsLayout.columns - 1
					background: Rectangle {
						anchors.fill: parent
						color: DefaultStyle.danger_500main
						radius: 71 * DefaultStyle.dp
					}
					onClicked: {
						mainWindow.endCall(mainWindow.call)
						mainWindow.callTerminatedByUser = true
					}
				}
				RowLayout {
					id: connectedCallButtons
					visible: false
					Layout.row: 0
					Layout.column: 1
					spacing: 10 * DefaultStyle.dp
					CheckableButton {
						id: pauseButton
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						icon.width: 32 * DefaultStyle.dp
						icon.height: 32 * DefaultStyle.dp
						background: Rectangle {
							anchors.fill: parent
							radius: 71 * DefaultStyle.dp
							color: parent.enabled
								? parent.checked
									? DefaultStyle.success_500main
									: parent.pressed
										? DefaultStyle.main2_400
										: DefaultStyle.grey_500
								: DefaultStyle.grey_600
						}
						enabled: mainWindow.callState != LinphoneEnums.CallState.PausedByRemote
						icon.source: enabled && checked ? AppIcons.play : AppIcons.pause
						checked: mainWindow.call && mainWindow.call.core.paused
						onCheckedChanged: {
							mainWindow.call.core.lSetPaused(!mainWindow.call.core.paused)
						}
					}
					CheckableButton {
						id: transferCallButton
						icon.source: AppIcons.transferCall
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						icon.width: 32 * DefaultStyle.dp
						icon.height: 32 * DefaultStyle.dp
						contentImageColor: enabled ? DefaultStyle.grey_0 : DefaultStyle.grey_500
						onCheckedChanged: {
							if (checked) {
								rightPanel.visible = true
								rightPanel.replace(contactsListPanel)
							} else {
								rightPanel.visible = false
							}
						}
						Connections {
							target: rightPanel
							onVisibleChanged: if(!rightPanel.visible) transferCallButton.checked = false
						}
					}
					CheckableButton {
						id: newCallButton
						checkable: false
						icon.source: AppIcons.newCall
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						icon.width: 32 * DefaultStyle.dp
						icon.height: 32 * DefaultStyle.dp
						onClicked: {
							var mainWin = UtilsCpp.getMainWindow()
							UtilsCpp.smartShowWindow(mainWin)
							mainWin.goToNewCall()
						}
					}
				}
				RowLayout {
					Layout.row: 0
					Layout.column: mainWindow.callState == LinphoneEnums.CallState.OutgoingInit
										|| mainWindow.callState == LinphoneEnums.CallState.OutgoingProgress
										|| mainWindow.callState == LinphoneEnums.CallState.OutgoingRinging
										|| mainWindow.callState == LinphoneEnums.CallState.OutgoingEarlyMedia
										|| mainWindow.callState == LinphoneEnums.CallState.IncomingReceived
										? bottomButtonsLayout.columns - 1 : 0
					spacing: 10 * DefaultStyle.dp
					CheckableButton {
						id: videoCameraButton
						enabled: mainWindow.conferenceInfo || (mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning)
						iconUrl: AppIcons.videoCamera
						checkedIconUrl: AppIcons.videoCameraSlash
						checked: mainWindow.call && !mainWindow.call.core.localVideoEnabled
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						icon.width: 32 * DefaultStyle.dp
						icon.height: 32 * DefaultStyle.dp
						onClicked: mainWindow.call.core.lSetLocalVideoEnabled(!mainWindow.call.core.localVideoEnabled)
					}
					CheckableButton {
						iconUrl: AppIcons.microphone
						checkedIconUrl: AppIcons.microphoneSlash
						checked: mainWindow.call && mainWindow.call.core.microphoneMuted
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						icon.width: 32 * DefaultStyle.dp
						icon.height: 32 * DefaultStyle.dp
						onClicked: mainWindow.call.core.lSetMicrophoneMuted(!mainWindow.call.core.microphoneMuted)
					}
					CheckableButton {
						iconUrl: AppIcons.screencast
						checkedColor: DefaultStyle.main2_400
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						icon.width: 32 * DefaultStyle.dp
						icon.height: 32 * DefaultStyle.dp
						onCheckedChanged: {
							if (checked) {
								rightPanel.visible = true
								rightPanel.replace(screencastPanel)
							} else {
								rightPanel.visible = false
							}
						}
					}
					CheckableButton {
						visible: false
						checkable: false
						checkedColor: DefaultStyle.main2_400
						iconUrl: AppIcons.handWaving
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						icon.width: 32 * DefaultStyle.dp
						icon.height: 32 * DefaultStyle.dp
					}
					CheckableButton {
						visible: false
						iconUrl: AppIcons.smiley
						checkedColor: DefaultStyle.main2_400
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						icon.width: 32 * DefaultStyle.dp
						icon.height: 32 * DefaultStyle.dp
					}
					CheckableButton {
						visible: mainWindow.conference
						iconUrl: AppIcons.usersTwo
						checkedColor: DefaultStyle.main2_400
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						icon.width: 32 * DefaultStyle.dp
						icon.height: 32 * DefaultStyle.dp
						onCheckedChanged: {
							if (checked) {
								rightPanel.visible = true
								rightPanel.replace(participantListPanel)
							} else {
								rightPanel.visible = false
							}
						}
					}
					PopupButton {
						id: moreOptionsButton
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						contentImageColor: enabled && !checked ? DefaultStyle.grey_0 : DefaultStyle.grey_500
						icon.source: AppIcons.more
						background: Rectangle {
							anchors.fill: moreOptionsButton
							color: moreOptionsButton.enabled
								? moreOptionsButton.checked 
									? DefaultStyle.main2_400
									: DefaultStyle.grey_500
								: DefaultStyle.grey_600
							radius: 40 * DefaultStyle.dp
						}
						popup.x: width/2
						Connections {
							target: moreOptionsButton.popup
							onOpened: {
								moreOptionsButton.popup.y = - moreOptionsButton.popup.height - moreOptionsButton.popup.padding
							}
						}
						component MenuButton: Button {
							background: Item{}
							icon.width: 32 * DefaultStyle.dp
							icon.height: 32 * DefaultStyle.dp
							textColor: down ? DefaultStyle.main1_500_main : DefaultStyle.main2_500main
							contentImageColor: down ? DefaultStyle.main1_500_main : DefaultStyle.main2_500main
							textSize: 14 * DefaultStyle.dp
							textWeight: 400 * DefaultStyle.dp
							spacing: 5 * DefaultStyle.dp
						}
						popup.contentItem: ColumnLayout {
							id: optionsList
							spacing: 5 * DefaultStyle.dp

							MenuButton {
								visible: mainWindow.conference
								Layout.fillWidth: true
								icon.source: AppIcons.squaresFour
								icon.width: 32 * DefaultStyle.dp
								icon.height: 32 * DefaultStyle.dp
								text: qsTr("Modifier la disposition")
								onClicked: {
									rightPanel.visible = true
									rightPanel.replace(changeLayoutPanel)
									moreOptionsButton.close()
								}
							}
							MenuButton {
								icon.source: AppIcons.callList
								Layout.fillWidth: true
								text: qsTr("Liste d'appel")
								onClicked: {
									rightPanel.visible = true
									rightPanel.replace(callsListPanel)
									moreOptionsButton.close()
								}
							}
							MenuButton {
								icon.source: AppIcons.dialer
								text: qsTr("Dialer")
								Layout.fillWidth: true
								onClicked: {
									rightPanel.visible = true
									rightPanel.replace(dialerPanel)
									moreOptionsButton.close()
								}
							}
							MenuButton {
								checkable: true
								enabled: mainWindow.call && mainWindow.call.core.recordable
								icon.source: AppIcons.recordFill
								icon.width: 32 * DefaultStyle.dp
								icon.height: 32 * DefaultStyle.dp
								contentImageColor: down 
									? DefaultStyle.main1_500_main
								 	:mainWindow.call && mainWindow.call.core.recording 
										? DefaultStyle.danger_500main 
										: DefaultStyle.main2_500main
								text: mainWindow.call && mainWindow.call.core.recording ? qsTr("Terminer l'enregistrement") : qsTr("Enregistrer l'appel")
								textColor: down 
									? DefaultStyle.main1_500_main
								 	:mainWindow.call && mainWindow.call.core.recording 
										? DefaultStyle.danger_500main
										: DefaultStyle.main2_500main
								Layout.fillWidth: true
								onCheckedChanged: {
									if (mainWindow.call)
										if (mainWindow.call.core.recording) mainWindow.call.core.lStopRecording()
										else mainWindow.call.core.lStartRecording()
								}
							}
							MenuButton {
								checkable: true
								icon.source: !mainWindow.call || mainWindow.call.core.speakerMuted ? AppIcons.speakerSlash : AppIcons.speaker
								icon.width: 32 * DefaultStyle.dp
								icon.height: 32 * DefaultStyle.dp
								contentImageColor: down 
									? DefaultStyle.main1_500_main
								 	: mainWindow.call && mainWindow.call.core.speakerMuted 
										? DefaultStyle.danger_500main 
										: DefaultStyle.main2_500main
								text: mainWindow.call && mainWindow.call.core.speakerMuted ? qsTr("Activer le son") : qsTr("Désactiver le son")
								textColor: down 
									? DefaultStyle.main1_500_main
								 	:mainWindow.call && mainWindow.call.core.speakerMuted 
										? DefaultStyle.danger_500main
										: DefaultStyle.main2_500main
								Layout.fillWidth: true
								onCheckedChanged: {
									if (mainWindow.call) mainWindow.call.core.lSetSpeakerMuted(!mainWindow.call.core.speakerMuted)
								}
							}
							MenuButton {
								Layout.fillWidth: true
								icon.source: AppIcons.settings
								text: qsTr("Paramètres")
								onClicked: {
									rightPanel.visible = true
									rightPanel.replace(settingsPanel)
									moreOptionsButton.close()
								}
							}
						}
					}
				}
			}
		}
	}
}
