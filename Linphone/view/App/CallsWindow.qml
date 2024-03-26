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
	onConferenceChanged: console.log ("CONFERENCE CHANGED", conference)

	property bool callTerminatedByUser: false
	
	onCallChanged: {
		console.log("CALL", call)
		// if conference, the main item is only
		// displayed when state is connected
		if (call && !conferenceInfo) middleItemStackView.replace(inCallItem)
	}
	Component.onCompleted: if (call && !conferenceInfo) middleItemStackView.replace(inCallItem)
	property var callObj

	function joinConference(withVideo) {
		if (!conferenceInfo || conferenceInfo.core.uri.length === 0) UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La conférence n'a pas pu démarrer en raison d'une erreur d'uri."))
		else {
			callObj = UtilsCpp.createCall(conferenceInfo.core.uri, withVideo)
		}
	}

	Connections {
		enabled: call != undefined && call != null
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
		console.log("State:", callState)
		if (callState === LinphoneEnums.CallState.Connected) {
			if (conferenceInfo) {
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
			console.log("Current call changed:"+currentCall)
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
				Control.StackView {
					id: middleItemStackView
					initialItem: waitingRoom
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.margins: 20 * DefaultStyle.dp
					
				}
				OngoingCallRightPanel {
					id: rightPanel
					Layout.fillHeight: true
					Layout.preferredWidth: 393 * DefaultStyle.dp
					property int currentIndex: 0
					Layout.rightMargin: 10 * DefaultStyle.dp
					visible: false
					function replace(id) {
						rightPanelStack.replace(id, Control.StackView.Immediate)
					}
					headerContent: Text {
						id: rightPanelTitle
						anchors.verticalCenter: parent.verticalCenter
						width: rightPanel.width
						color: DefaultStyle.main2_700
						// text: qsTr("Transfert d'appel")
						font {
							pixelSize: 16 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
					}
					Control.StackView {
						id: rightPanelStack
						width: parent.width
						height: parent.height
						initialItem: callsListPanel
						Component {
							id: contactsListPanel
							CallContactsLists {
								Control.StackView.onActivated: rightPanelTitle.text = qsTr("Transfert d'appel")
								sideMargin: 10 * DefaultStyle.dp
								topMargin: 15 * DefaultStyle.dp
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
								Control.StackView.onActivated: rightPanelTitle.text = qsTr("Dialer")
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
									property var callObj
									NumericPad {
										id: numPad
										width: parent.width
										visible: parent.visible
										closeButtonVisible: false
										onLaunchCall: {
											callObj = UtilsCpp.createCall(dialerTextInput.text + "@sip.linphone.org")
										}
									}
								}
							}
						}
						Component {
							id: callsListPanel
							ColumnLayout {
								Control.StackView.onActivated: rightPanelTitle.text = qsTr("Liste d'appel")
								RoundedBackgroundControl {
									Layout.fillWidth: true
									// height: Math.min(callList.height + topPadding + bottomPadding, rightPanelStack.height)
									Layout.preferredHeight: Math.min(callList.height + topPadding + bottomPadding, rightPanelStack.height)

									topPadding: 15 * DefaultStyle.dp
									bottomPadding: 15 * DefaultStyle.dp
									leftPadding: 15 * DefaultStyle.dp
									rightPadding: 15 * DefaultStyle.dp
									backgroundColor: DefaultStyle.main2_0
									
									contentItem: ListView {
										id: callList
										model: callsModel
										height: Math.min(contentHeight, rightPanelStack.height)
										spacing: 15 * DefaultStyle.dp

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
														Control.Button {
															background: Item {}
															contentItem: RowLayout {
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
														Control.Button {
															background: Item {}
															contentItem: RowLayout {
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
												
											// MouseArea{
											// 	anchors.fill: delegateLayout
											// 	onClicked: {
											// 		callsModel.currentCall = modelData
											// 	}
											// }
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
								Control.StackView.onActivated: rightPanelTitle.text = qsTr("Paramètres")
								call: mainWindow.call
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
					Connections {
						target: mainWindow
						onCallChanged: if (mainWindow.conferenceInfo && mainWindow.call) {
							mainWindow.call.core.lSetCameraEnabled(waitingRoomIn.cameraEnabled)
							mainWindow.call.core.lSetMicrophoneMuted(!waitingRoomIn.microEnabled)
						}
					}
					onJoinConfRequested: mainWindow.joinConference(cameraEnabled)
				}
			}
			
			
			
			
			Component {
				id: inCallItem
				Control.Control {
					Layout.fillWidth: true
					implicitWidth: 1059 * DefaultStyle.dp
					// implicitHeight: parent.height
					Layout.fillHeight: true
					Layout.leftMargin: 10 * DefaultStyle.dp

					Layout.rightMargin: 10 * DefaultStyle.dp
					Layout.alignment: Qt.AlignCenter
					/*
					background: Rectangle {
						anchors.fill: parent
						color: DefaultStyle.grey_600
						radius: 15 * DefaultStyle.dp
					}*/
					contentItem: CallLayout{
						call: mainWindow.call
						callTerminatedByUser: mainWindow.callTerminatedByUser
					}
				}
			}
			GridLayout {
				id: bottomButtonsLayout
				rows: 1
				columns: 3
				Layout.alignment: Qt.AlignHCenter
				layoutDirection: Qt.LeftToRight
				columnSpacing: 20 * DefaultStyle.dp
				visible: mainWindow.call && !mainWindow.conferenceInfo

				function refreshLayout() {
					if (mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning) {
						bottomButtonsLayout.layoutDirection = Qt.RightToLeft
						connectedCallButtons.visible = bottomButtonsLayout.visible
						moreOptionsButton.visible = bottomButtonsLayout.visible
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
					contentImageColor: DefaultStyle.grey_0
					checkable: false
					Layout.column: mainWindow.callState == LinphoneEnums.CallState.OutgoingInit
										|| mainWindow.callState == LinphoneEnums.CallState.OutgoingProgress
										|| mainWindow.callState == LinphoneEnums.CallState.OutgoingRinging
										|| mainWindow.callState == LinphoneEnums.CallState.OutgoingEarlyMedia
										|| mainWindow.callState == LinphoneEnums.CallState.IncomingReceived
										? 0 : bottomButtonsLayout.columns - 1
					Layout.preferredWidth: 75 * DefaultStyle.dp
					Layout.preferredHeight: 55 * DefaultStyle.dp
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
					CheckableButton {
						id: pauseButton
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
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
						contentImageColor: enabled ? DefaultStyle.grey_0 : DefaultStyle.grey_500
						onEnabledChanged: console.log("===================enable change", enabled)
						onContentImageColorChanged: console.log("===================================== content image color", contentImageColor)
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
					CheckableButton {
						id: videoCameraButton
						enabled: mainWindow.conferenceInfo || (mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning)
						iconUrl: AppIcons.videoCamera
						checkedIconUrl: AppIcons.videoCameraSlash
						checked: mainWindow.call && !mainWindow.call.core.cameraEnabled
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						onCheckedChanged: mainWindow.call.core.lSetCameraEnabled(!mainWindow.call.core.cameraEnabled)
					}
					CheckableButton {
						iconUrl: AppIcons.microphone
						checkedIconUrl: AppIcons.microphoneSlash
						checked: mainWindow.call && mainWindow.call.core.microphoneMuted
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						onCheckedChanged: mainWindow.call.core.lSetMicrophoneMuted(!mainWindow.call.core.microphoneMuted)
					}
					PopupButton {
						id: moreOptionsButton
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						onEnabledChanged: console.log("========== enabled changed", enabled)
						contentImageColor: enabled && !checked ? DefaultStyle.grey_0 : DefaultStyle.grey_500
						icon.width: 24 * DefaultStyle.dp
						icon.height: 24 * DefaultStyle.dp
						icon.source: AppIcons.more
						background: Rectangle {
							anchors.fill: moreOptionsButton
							color: moreOptionsButton.enabled 
								? moreOptionsButton.checked 
									? DefaultStyle.grey_0 
									: DefaultStyle.grey_500
								: DefaultStyle.grey_600
							radius: 40 * DefaultStyle.dp
						}
						popup.x: width/2
						popup.y: y - popup.height + height/4
						popup.contentItem: ColumnLayout {
							id: optionsList
							spacing: 10 * DefaultStyle.dp
							
							Button {
								id: callListButton
								Layout.fillWidth: true
								background: Item {}
								contentItem: RowLayout {
									Image {
										Layout.preferredWidth: 24 * DefaultStyle.dp
										Layout.preferredHeight: 24 * DefaultStyle.dp
										fillMode: Image.PreserveAspectFit
										source: AppIcons.callList
									}
									Text {
										text: qsTr("Liste d'appel")
									}
								}
								onClicked: {
									rightPanel.visible = true
									rightPanel.replace(callsListPanel)
									moreOptionsButton.close()
								}
							}
							Button {
								id: dialerButton
								Layout.fillWidth: true
								background: Item {}
								contentItem: RowLayout {
									Image {
										Layout.preferredWidth: 24 * DefaultStyle.dp
										Layout.preferredHeight: 24 * DefaultStyle.dp
										fillMode: Image.PreserveAspectFit
										source: AppIcons.dialer
									}
									Text {
										text: qsTr("Dialer")
									}
								}
								onClicked: {
									rightPanel.visible = true
									rightPanel.replace(dialerPanel)
									moreOptionsButton.close()
								}
							}
							Button {
								id: recordButton
								Layout.fillWidth: true
								enabled: mainWindow.call && mainWindow.call.core.recordable
								checkable: true
								background: Item {}
								contentItem: RowLayout {
									EffectImage {
										Layout.preferredWidth: 24 * DefaultStyle.dp
										Layout.preferredHeight: 24 * DefaultStyle.dp
										fillMode: Image.PreserveAspectFit
										imageSource: AppIcons.recordFill
										colorizationColor: mainWindow.call && mainWindow.call.core.recording ? DefaultStyle.danger_500main : undefined
									}
									Text {
										color: mainWindow.call && mainWindow.call.core.recording ? DefaultStyle.danger_500main : DefaultStyle.main2_600
										text: mainWindow.call && mainWindow.call.core.recording ? qsTr("Terminer l'enregistrement") : qsTr("Enregistrer l'appel")
									}

								}
								onClicked: {
									mainWindow.call && mainWindow.call.core.recording ? mainWindow.call.core.lStopRecording() : mainWindow.call.core.lStartRecording()
								}
							}
							Button {
								id: settingsButton
								Layout.fillWidth: true
								background: Item{}
								contentItem: RowLayout {
									Image {
										Layout.preferredWidth: 24 * DefaultStyle.dp
										Layout.preferredHeight: 24 * DefaultStyle.dp
										source: AppIcons.settings
									}
									Text {
										text: qsTr("Paramètres")
									}
								}
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
