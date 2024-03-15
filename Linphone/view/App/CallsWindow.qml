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
	property ConferenceGui conference: call && call.core.conference || null
	property bool callTerminatedByUser: false

	Connections {
		target: call.core
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

	onCallChanged: {
		waitingTime.seconds = 0
		waitingTimer.restart()
		console.log("call changed", call, waitingTime.seconds)
	}

	property var callState: call.core.state
	onCallStateChanged: {
		console.log("State:", callState)
		if (callState === LinphoneEnums.CallState.Connected) {
			if(!call.core.isSecured && call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp) {
				zrtpValidation.open()
			}
		}
		else if (callState === LinphoneEnums.CallState.Error || callState === LinphoneEnums.CallState.End) {
			callEnded(call)
		}
	}
	property var transferState: call.core.transferState
	onTransferStateChanged: {
		console.log("Transfer state:", transferState)
		if (call.core.transferState === LinphoneEnums.CallState.Error) {
			transferErrorPopup.visible = true

		}
		else if (call.core.transferState === LinphoneEnums.CallState.Connected){
			var mainWin = UtilsCpp.getMainWindow()
			UtilsCpp.smartShowWindow(mainWin)
			mainWin.transferCallSucceed()
		}
	}
	onClosing: (close) => {
		close.accepted = false
		if (callsModel.haveCall)
			terminateAllCallsDialog.open()
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
		visible: mainWindow.call.core.transferState === LinphoneEnums.CallState.OutgoingInit
					|| mainWindow.call.core.transferState === LinphoneEnums.CallState.OutgoingProgress
					|| mainWindow.call.core.transferState === LinphoneEnums.CallState.OutgoingRinging || false
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
						width: 15 * DefaultStyle.dp
						height: 15 * DefaultStyle.dp
						imageSource:(mainWindow.call.core.state === LinphoneEnums.CallState.End
							|| mainWindow.call.core.state === LinphoneEnums.CallState.Released)
							? AppIcons.endCall
							: (mainWindow.call.core.state === LinphoneEnums.CallState.Paused
							|| mainWindow.call.core.state === LinphoneEnums.CallState.PausedByRemote)
								? AppIcons.pause
								: mainWindow.call.core.dir === LinphoneEnums.CallDir.Outgoing
									? AppIcons.outgoingCall
									: AppIcons.incomingCall
						colorizationColor: mainWindow.call.core.state === LinphoneEnums.CallState.Paused
							|| mainWindow.call.core.state === LinphoneEnums.CallState.PausedByRemote || mainWindow.call.core.state === LinphoneEnums.CallState.End
							|| mainWindow.call.core.state === LinphoneEnums.CallState.Released ? DefaultStyle.danger_500main : undefined
					}
					Text {
						id: callStatusText
						text: (mainWindow.call.core.state === LinphoneEnums.CallState.End  || mainWindow.call.core.state === LinphoneEnums.CallState.Released)
							? qsTr("End of the call")
							: (mainWindow.call.core.state === LinphoneEnums.CallState.Paused
							|| mainWindow.call.core.state === LinphoneEnums.CallState.PausedByRemote)
								? qsTr("Appel mis en pause")
								: mainWindow.conference
									? mainWindow.conference.core.subject
									: EnumsToStringCpp.dirToString(mainWindow.call.core.dir) + qsTr(" call")
						color: DefaultStyle.grey_0
						font {
							pixelSize: 22 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
					}
					Rectangle {
						visible: mainWindow.call.core.state === LinphoneEnums.CallState.Connected
								|| mainWindow.call.core.state === LinphoneEnums.CallState.StreamsRunning
						Layout.preferredHeight: parent.height
						Layout.preferredWidth: 2 * DefaultStyle.dp
					}
					Text {
						text: UtilsCpp.formatElapsedTime(mainWindow.call.core.duration)
						color: DefaultStyle.grey_0
						font {
							pixelSize: 22 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
						visible: mainWindow.call.core.state === LinphoneEnums.CallState.Connected
								|| mainWindow.call.core.state === LinphoneEnums.CallState.StreamsRunning
					}
					Item {
						Layout.fillWidth: true
					}
					RowLayout {
						visible: mainWindow.call.core.recording || mainWindow.call.core.remoteRecording
						Text {
							color: DefaultStyle.danger_500main
							font.pixelSize: 14 * DefaultStyle.dp
							text: mainWindow.call.core.recording ? qsTr("Vous enregistrez l'appel") : qsTr("Votre correspondant enregistre l'appel")
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
					anchors.centerIn: parent
					topPadding: 8 * DefaultStyle.dp
					bottomPadding: 8 * DefaultStyle.dp
					leftPadding: 10 * DefaultStyle.dp
					rightPadding: 10 * DefaultStyle.dp
					width: 269 * DefaultStyle.dp
					visible: mainWindow.call && mainWindow.call.core.isSecured
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
				Control.Control {
					Layout.fillWidth: true
					Layout.preferredWidth: 1059 * DefaultStyle.dp
					Layout.fillHeight: true
					Layout.leftMargin: 10 * DefaultStyle.dp
					Layout.rightMargin: 10 * DefaultStyle.dp
					Layout.alignment: Qt.AlignCenter
					background: Rectangle {
						anchors.fill: parent
						color: DefaultStyle.grey_600
						radius: 15 * DefaultStyle.dp
					}
					contentItem: Item {
						id: centerItem
						anchors.fill: parent
						Text {
							id: callTerminatedText
							Connections {
								target: mainWindow
								onCallStateChanged: {
									if (mainWindow.call.core.state === LinphoneEnums.CallState.End) {
										callTerminatedText.visible = true
									}
								}
							}
							visible: false
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.top: parent.top
							anchors.topMargin: 25 * DefaultStyle.dp
							text: mainWindow.callTerminatedByUser ? qsTr("Vous avez terminé l'appel") : qsTr("Votre correspondant a terminé l'appel")
							color: DefaultStyle.grey_0
							z: 1
							font {
								pixelSize: 22 * DefaultStyle.dp
								weight: 300 * DefaultStyle.dp
							}
						}
						StackLayout {
							id: centerLayout
							currentIndex: 0
							anchors.fill: parent
							Connections {
								target: mainWindow
								onCallStateChanged: {
									if (mainWindow.call.core.state === LinphoneEnums.CallState.Error) {
										centerLayout.currentIndex = 1
									}
								}
							}
							Sticker {
								call: mainWindow.call
								Layout.fillWidth: true
								Layout.fillHeight: true
								// visible: mainWindow.call.core.state != LinphoneEnums.CallState.End

								Timer {
									id: waitingTimer
									interval: 1000
									repeat: true
									onTriggered: waitingTime.seconds += 1
								}
								ColumnLayout {
									anchors.horizontalCenter: parent.horizontalCenter
									anchors.top: parent.top
									anchors.topMargin: 30 * DefaultStyle.dp
									visible: mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingInit
											|| mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingProgress
											|| mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingRinging
											|| mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingEarlyMedia
											|| mainWindow.call.core.state == LinphoneEnums.CallState.IncomingReceived
									BusyIndicator {
										indicatorColor: DefaultStyle.main2_100
										Layout.alignment: Qt.AlignHCenter
									}
									Text {
										id: waitingTime
										property int seconds
										text: UtilsCpp.formatElapsedTime(seconds)
										color: DefaultStyle.grey_0
										Layout.alignment: Qt.AlignHCenter
										horizontalAlignment: Text.AlignHCenter
										font {
											pixelSize: 30 * DefaultStyle.dp
											weight: 300 * DefaultStyle.dp
										}
										Component.onCompleted: {
											waitingTimer.restart()
										}
									}
								}
							}
							ColumnLayout {
								id: userNotFoundLayout
								Layout.preferredWidth: parent.width
								Layout.preferredHeight: parent.height
								Layout.alignment: Qt.AlignCenter
								Text {
									text: qsTr(mainWindow.call.core.lastErrorMessage)
									Layout.alignment: Qt.AlignCenter
									color: DefaultStyle.grey_0
									font.pixelSize: 40 * DefaultStyle.dp
								}
							}
						}
						Sticker {
							id: preview
							visible: mainWindow.call.core.state != LinphoneEnums.CallState.End
								&& mainWindow.call.core.state != LinphoneEnums.CallState.Released
							height: 180 * DefaultStyle.dp
							width: 300 * DefaultStyle.dp
							anchors.right: centerItem.right
							anchors.bottom: centerItem.bottom
							anchors.rightMargin: 10 * DefaultStyle.dp
							anchors.bottomMargin: 10 * DefaultStyle.dp
							AccountProxy{
								id: accounts
							}
							account: accounts.defaultAccount
							enablePersonalCamera: mainWindow.call.core.cameraEnabled

							MovableMouseArea {
								id: previewMouseArea
								anchors.fill: parent
								// visible: mainItem.participantCount <= 2
								movableArea: centerItem
								margin: 10 * DefaultStyle.dp
								function resetPosition(){
									preview.anchors.right = centerItem.right
									preview.anchors.bottom = centerItem.bottom
									preview.anchors.rightMargin = previewMouseArea.margin
									preview.anchors.bottomMargin = previewMouseArea.margin
								}
								onVisibleChanged: if(!visible){
									resetPosition()
								}
								drag.target: preview
								onDraggingChanged: if(dragging) {
									preview.anchors.right = undefined
									preview.anchors.bottom = undefined
								}
								onRequestResetPosition: resetPosition()
							}
						}
						property int previousWidth
						Component.onCompleted: {
							previousWidth = width
						}
						onWidthChanged: {
							if (width < previousWidth) {
								previewMouseArea.updatePosition(0, 0)
							} else {
								previewMouseArea.updatePosition(width - previousWidth, 0)
							}
							previousWidth = width
						}
					}
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
								sideMargin: 10 * DefaultStyle.dp
								topMargin: 15 * DefaultStyle.dp
								groupCallVisible: false
								searchBarColor: DefaultStyle.grey_0
								searchBarBorderColor: DefaultStyle.grey_200
								onCallButtonPressed: (address) => {
									mainWindow.call.core.lTransferCall(address)
								}
								Control.StackView.onActivated: rightPanelTitle.text = qsTr("Transfert d'appel")
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
								RoundedBackgroundControl {
									Control.StackView.onActivated: rightPanelTitle.text = qsTr("Liste d'appel")
									Layout.fillWidth: true
									// height: Math.min(callList.height + topPadding + bottomPadding, rightPanelStack.height)
									onHeightChanged: console.log("calls list height changed", height)
									height: Math.min(callList.height + topPadding + bottomPadding, rightPanelStack.height)

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
							ColumnLayout {
								RoundedBackgroundControl {
									Layout.alignment: Qt.AlignHCenter
									Control.StackView.onActivated: {
										rightPanelTitle.text = qsTr("Paramètres")
									}
									backgroundColor: DefaultStyle.main2_0
									height: contentItem.implicitHeight + topPadding + bottomPadding
									Layout.fillWidth: true
									topPadding: 25 * DefaultStyle.dp
									bottomPadding: 25 * DefaultStyle.dp
									leftPadding: 25 * DefaultStyle.dp
									rightPadding: 25 * DefaultStyle.dp
									contentItem: ColumnLayout {
										spacing: 10 * DefaultStyle.dp

										RowLayout {
											Layout.fillWidth: true
											EffectImage {
												imageSource: AppIcons.speaker
												colorizationColor: DefaultStyle.main1_500_main
												Layout.preferredWidth: 24 * DefaultStyle.dp
												Layout.preferredHeight: 24 * DefaultStyle.dp
												imageWidth: 24 * DefaultStyle.dp
												imageHeight: 24 * DefaultStyle.dp
											}
											Text {
												text: qsTr("Haut-parleurs")
												Layout.fillWidth: true
											}
										}
										ComboBox {
											Layout.fillWidth: true
											Layout.preferredWidth: parent.width
											model: SettingsCpp.outputAudioDevicesList
											onCurrentTextChanged: {
												mainWindow.call.core.lSetOutputAudioDevice(currentText)
											}
										}
										Slider {
											id: speakerVolume
											Layout.fillWidth: true
											from: 0.0
											to: 1.0
											value: mainWindow.call && mainWindow.call.core.speakerVolumeGain
											onMoved: {
												mainWindow.call.core.lSetSpeakerVolumeGain(value)
											}
										}
										RowLayout {
											Layout.fillWidth: true
											EffectImage {
												imageSource: AppIcons.microphone
												colorizationColor: DefaultStyle.main1_500_main
												Layout.preferredWidth: 24 * DefaultStyle.dp
												Layout.preferredHeight: 24 * DefaultStyle.dp
												imageWidth: 24 * DefaultStyle.dp
												imageHeight: 24 * DefaultStyle.dp
											}
											Text {
												text: qsTr("Microphone")
												Layout.fillWidth: true
											}
										}
										ComboBox {
											Layout.fillWidth: true
											Layout.preferredWidth: parent.width
											model: SettingsCpp.inputAudioDevicesList
											onCurrentTextChanged: {
												mainWindow.call.core.lSetInputAudioDevice(currentText)
											}
										}
										Slider {
											id: microVolume
											Layout.fillWidth: true
											from: 0.0
											to: 1.0
											value: mainWindow.call && mainWindow.call.core.microphoneVolumeGain
											onMoved: {
												mainWindow.call.core.lSetMicrophoneVolumeGain(value)
											}
										}
										Timer {
											interval: 50
											repeat: true
											running: mainWindow.call || false
											onTriggered: audioTestSlider.value = (mainWindow.call && mainWindow.call.core.microVolume)
										}
										Slider {
											id: audioTestSlider
											Layout.fillWidth: true
											enabled: false
											Layout.preferredHeight: 10 * DefaultStyle.dp

											background: Rectangle {
												x: audioTestSlider.leftPadding
												y: audioTestSlider.topPadding + audioTestSlider.availableHeight / 2 - height / 2
												implicitWidth: 200 * DefaultStyle.dp
												implicitHeight: 10 * DefaultStyle.dp
												width: audioTestSlider.availableWidth
												height: implicitHeight
												radius: 2 * DefaultStyle.dp
												color: "#D9D9D9"

												Rectangle {
													width: audioTestSlider.visualPosition * parent.width
													height: parent.height
													gradient: Gradient {
														orientation: Gradient.Horizontal
														GradientStop { position: 0.0; color: "#6FF88D" }
														GradientStop { position: 1.0; color: "#00D916" }
													}
													radius: 2 * DefaultStyle.dp
												}
											}
											handle: Item {visible: false}
										}
										RowLayout {
											Layout.fillWidth: true
											EffectImage {
												imageSource: AppIcons.videoCamera
												colorizationColor: DefaultStyle.main1_500_main
												Layout.preferredWidth: 24 * DefaultStyle.dp
												Layout.preferredHeight: 24 * DefaultStyle.dp
												imageWidth: 24 * DefaultStyle.dp
												imageHeight: 24 * DefaultStyle.dp
											}
											Text {
												text: qsTr("Caméra")
												Layout.fillWidth: true
											}
										}
										ComboBox {
											Layout.fillWidth: true
											Layout.preferredWidth: parent.width
											model: SettingsCpp.videoDevicesList
											onCurrentTextChanged: {
												SettingsCpp.lSetVideoDevice(currentText)
											}
										}
									}
								}
								Item {
									Layout.fillHeight: true
								}
							}
						}
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

				function refreshLayout() {
					if (mainWindow.call.core.state === LinphoneEnums.CallState.Connected || mainWindow.call.core.state === LinphoneEnums.CallState.StreamsRunning) {
						bottomButtonsLayout.layoutDirection = Qt.RightToLeft
						connectedCallButtons.visible = true
						videoCameraButton.enabled = true
						moreOptionsButton.visible = true
					} 
					else if (mainWindow.callState === LinphoneEnums.CallState.OutgoingInit) {
						connectedCallButtons.visible = false
						bottomButtonsLayout.layoutDirection = Qt.LeftToRight
						videoCameraButton.enabled = false
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
				BottomButton {
					Layout.row: 0
					enabledIcon: AppIcons.endCall
					checkable: false
					Layout.column: mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingInit
										|| mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingProgress
										|| mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingRinging
										|| mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingEarlyMedia
										|| mainWindow.call.core.state == LinphoneEnums.CallState.IncomingReceived
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
					BottomButton {
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
						enabled: mainWindow.call.core.state != LinphoneEnums.CallState.PausedByRemote
						enabledIcon: enabled && checked ? AppIcons.play : AppIcons.pause
						checked: mainWindow.call.core.paused
						onClicked: {
							mainWindow.call.core.lSetPaused(!callsModel.currentCall.core.paused)
						}
					}
					BottomButton {
						id: transferCallButton
						enabledIcon: AppIcons.transferCall
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
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
					BottomButton {
						id: newCallButton
						checkable: false
						enabledIcon: AppIcons.newCall
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
					Layout.column: mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingInit
										|| mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingProgress
										|| mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingRinging
										|| mainWindow.call.core.state == LinphoneEnums.CallState.OutgoingEarlyMedia
										|| mainWindow.call.core.state == LinphoneEnums.CallState.IncomingReceived
										? bottomButtonsLayout.columns - 1 : 0
					BottomButton {
						id: videoCameraButton
						enabledIcon: AppIcons.videoCamera
						disabledIcon: AppIcons.videoCameraSlash
						checked: !mainWindow.call.core.cameraEnabled
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						onClicked: mainWindow.call.core.lSetCameraEnabled(!mainWindow.call.core.cameraEnabled)
					}
					BottomButton {
						enabledIcon: AppIcons.microphone
						disabledIcon: AppIcons.microphoneSlash
						checked: mainWindow.call.core.microphoneMuted
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						onClicked: mainWindow.call.core.lSetMicrophoneMuted(!mainWindow.call.core.microphoneMuted)
					}
					PopupButton {
						id: moreOptionsButton
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						background: Rectangle {
							anchors.fill: moreOptionsButton
							color: moreOptionsButton.checked ? DefaultStyle.grey_0 : DefaultStyle.grey_500
							radius: 40 * DefaultStyle.dp
						}
						contentItem: Item {
							EffectImage {
								imageSource: AppIcons.more
								width: 24 * DefaultStyle.dp
								height: 24 * DefaultStyle.dp
								anchors.centerIn: parent
								colorizationColor: moreOptionsButton.checked ? DefaultStyle.grey_500 : DefaultStyle.grey_0
							}
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
								enabled: mainWindow.call.core.recordable
								checkable: true
								background: Item {}
								contentItem: RowLayout {
									EffectImage {
										Layout.preferredWidth: 24 * DefaultStyle.dp
										Layout.preferredHeight: 24 * DefaultStyle.dp
										fillMode: Image.PreserveAspectFit
										imageSource: AppIcons.recordFill
										colorizationColor: mainWindow.call.core.recording ? DefaultStyle.danger_500main : undefined
									}
									Text {
										color: mainWindow.call.core.recording ? DefaultStyle.danger_500main : DefaultStyle.main2_600
										text: mainWindow.call.core.recording ? qsTr("Terminer l'enregistrement") : qsTr("Enregistrer l'appel")
									}

								}
								onClicked: {
									mainWindow.call.core.recording ? mainWindow.call.core.lStopRecording() : mainWindow.call.core.lStartRecording()
								}
							}
							Control.Button {
								id: speakerButton
								Layout.fillWidth: true
								checkable: true
								background: Item {}
								contentItem: RowLayout {
									EffectImage {
										Layout.preferredWidth: 24 * DefaultStyle.dp
										Layout.preferredHeight: 24 * DefaultStyle.dp
										fillMode: Image.PreserveAspectFit
										imageSource: AppIcons.recordFill
										colorizationColor: mainWindow.call.core.recording ? DefaultStyle.danger_500main : undefined
									}
									Text {
										color: mainWindow.call.core.recording ? DefaultStyle.danger_500main : DefaultStyle.main2_600
										text: mainWindow.call.core.recording ? qsTr("Terminer l'enregistrement") : qsTr("Enregistrer l'appel")
									}

								}
								onClicked: {
									mainWindow.call.core.recording ? mainWindow.call.core.lStopRecording() : mainWindow.call.core.lStartRecording()
								}
							}
							Control.Button {
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
