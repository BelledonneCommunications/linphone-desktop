import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls as Control
import Linphone
import EnumsToStringCpp 1.0
import UtilsCpp 1.0

Window {
	id: mainWindow
	width: 1512 * DefaultStyle.dp
	height: 982 * DefaultStyle.dp
	flags: Qt.Window
	// modality: Qt.WindowModal

	property CallGui call

	onCallChanged: {
		waitingTime.seconds = 0
		waitingTimer.restart()
		console.log("call changed", call, waitingTime.seconds)
	}

	property var peerName: UtilsCpp.getDisplayName(call.core.peerAddress)
	property string peerNameText: peerName ? peerName.value : ""

	property var callState: call.core.state
	onCallStateChanged: {
		console.log("State:", callState)
		if (callState === LinphoneEnums.CallState.Error || callState === LinphoneEnums.CallState.End) {
			endCall(call)
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
		if (!callsModel.haveCall) {
			bottomButtonsLayout.setButtonsEnabled(false)
			autoCloseWindow.restart()
		} else if (callToFinish.core === mainWindow.call.core) {
			mainWindow.call = callsModel.currentCall
		}
	}

	Popup {
		id: terminateAllCallsDialog
		modal: true
		anchors.centerIn: parent
		closePolicy: Control.Popup.NoAutoClose
		padding: 10 * DefaultStyle.dp
		contentItem: ColumnLayout {
			height: terminateAllCallsDialog.height
			width: 278 * DefaultStyle.dp
			spacing: 8 * DefaultStyle.dp
			Text {
				text: qsTr("La fenêtre est sur le point d'être fermée. Cela terminera tous les appels en cours. Souhaitez vous continuer ?")
				Layout.preferredWidth: parent.width
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 400 * DefaultStyle.dp
				}
				wrapMode: Text.Wrap
				horizontalAlignment: Text.AlignHCenter
			}
			RowLayout {
				Layout.alignment: Qt.AlignHCenter
				Button {
					text: qsTr("Oui")
					onClicked: {
						call.core.lTerminateAllCalls()
						terminateAllCallsDialog.close()
					}
				}
				Button {
					text: qsTr("Non")
					onClicked: terminateAllCallsDialog.close()
				}
			}
		}
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
		padding: 18 * DefaultStyle.dp
		checkable: true
		background: Rectangle {
			anchors.fill: parent
			RectangleTest{}
			color: bottomButton.enabled
					? disabledIcon
						? DefaultStyle.grey_500
						: bottomButton.pressed || bottomButton.checked
							? DefaultStyle.main2_400
							: DefaultStyle.grey_500
					: DefaultStyle.grey_600
			radius: 71 * DefaultStyle.dp
		}
		contentItem: EffectImage {
			image.source: disabledIcon && bottomButton.checked ? disabledIcon : enabledIcon
			anchors.fill: parent
			image.width: 32 * DefaultStyle.dp
			image.height: 32 * DefaultStyle.dp
			colorizationColor: disabledIcon && bottomButton.checked ? DefaultStyle.main2_0 : DefaultStyle.grey_0
		}
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
			spacing: 5 * DefaultStyle.dp
			anchors.bottomMargin: 5 * DefaultStyle.dp
			Item {
				Layout.margins: 10 * DefaultStyle.dp
				Layout.fillWidth: true
				Layout.minimumHeight: 25 * DefaultStyle.dp
				RowLayout {
					anchors.verticalCenter: parent.verticalCenter
					spacing: 10 * DefaultStyle.dp
					EffectImage {
						id: callStatusIcon
						image.fillMode: Image.PreserveAspectFit
						image.width: 15 * DefaultStyle.dp
						image.height: 15 * DefaultStyle.dp
						image.sourceSize.width: 15 * DefaultStyle.dp
						image.sourceSize.height: 15 * DefaultStyle.dp
						image.source: mainWindow.call.core.paused
							? AppIcons.pause
							: (mainWindow.call.core.state === LinphoneEnums.CallState.End
							|| mainWindow.call.core.state === LinphoneEnums.CallState.Released)
								? AppIcons.endCall
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
							: (mainWindow.call.core.paused)
								? qsTr("Appel mis en pause")
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
				}

				Control.Control {
					anchors.centerIn: parent
					topPadding: 8 * DefaultStyle.dp
					bottomPadding: 8 * DefaultStyle.dp
					leftPadding: 10 * DefaultStyle.dp
					rightPadding: 10 * DefaultStyle.dp
					visible: mainWindow.call.core.peerSecured
					onVisibleChanged: console.log("peer secured", mainWindow.call.core.peerSecured)
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
					id: centerItem
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
						anchors.fill: parent
						StackLayout {
							id: centerLayout
							anchors.fill: parent
							Connections {
								target: mainWindow
								onCallStateChanged: {
									if (mainWindow.call.core.state === LinphoneEnums.CallState.Error) {
										centerLayout.currentIndex = 2
									}
								}
							}
							Item {
								id: audioCallItem
								Layout.alignment: Qt.AlignHCenter
								Layout.preferredWidth: parent.width
								Layout.preferredHeight: parent.height
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
								ColumnLayout {
									anchors.centerIn: parent
									spacing: 2 * DefaultStyle.dp
									Avatar {
										Layout.alignment: Qt.AlignCenter
										// TODO : remove username when friend list ready
										call: mainWindow.call
										// address: mainWindow.peerNameText
										Layout.preferredWidth: 120 * DefaultStyle.dp
										Layout.preferredHeight: 120 * DefaultStyle.dp
									}
									Text {
										Layout.alignment: Qt.AlignCenter
										Layout.topMargin: 15 * DefaultStyle.dp
										visible: mainWindow.peerNameText.length > 0
										text: mainWindow.peerNameText
										color: DefaultStyle.grey_0
										font {
											pixelSize: 22 * DefaultStyle.dp
											weight: 300 * DefaultStyle.dp
											capitalization: Font.Capitalize
										}
									}
									Text {
										Layout.alignment: Qt.AlignCenter
										text: mainWindow.call.core.peerAddress
										color: DefaultStyle.grey_0
										font {
											pixelSize: 14 * DefaultStyle.dp
											weight: 300 * DefaultStyle.dp
										}
									}
								}
							}
							Image {
								id: videoCallItem
								Layout.preferredWidth: parent.width
								Layout.preferredHeight: parent.height
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
						Text {
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.bottom: parent.bottom
							anchors.leftMargin: 10 * DefaultStyle.dp
							anchors.bottomMargin: 10 * DefaultStyle.dp
							text: mainWindow.peerNameText
							color: DefaultStyle.grey_0
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 500 * DefaultStyle.dp
							}
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
					contentItem: Control.StackView {
						id: rightPanelStack
					}
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
								NumericPad {
									id: numPad
									width: parent.width
									visible: parent.visible
									closeButtonVisible: false
									onLaunchCall: {
										var callVarObject = UtilsCpp.createCall(dialerTextInput.text + "@sip.linphone.org")
									}
								}
							}
						}
					}
					Component {
						id: callsListPanel
						Control.Control {
							Control.StackView.onActivated: rightPanelTitle.text = qsTr("Liste d'appel")
							// width: callList.width
							// height: callList.height
							onHeightChanged: console.log("control height changed", height)

							// padding: 15 * DefaultStyle.dp
							topPadding: 15 * DefaultStyle.dp
							bottomPadding: 15 * DefaultStyle.dp
							leftPadding: 15 * DefaultStyle.dp
							rightPadding: 15 * DefaultStyle.dp
							
							background: Rectangle {
								anchors.fill: parent
								anchors.leftMargin: 10 * DefaultStyle.dp
								anchors.rightMargin: 10 * DefaultStyle.dp
								anchors.topMargin: 10 * DefaultStyle.dp
								anchors.bottomMargin: 10 * DefaultStyle.dp
								color: DefaultStyle.main2_0
								radius: 15 * DefaultStyle.dp
							}

							contentItem: ListView {
								id: callList
								model: callsModel
								height: contentHeight
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
											text: UtilsCpp.getDisplayName(modelData.core.peerAddress).value
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
															image.source: AppIcons.endCall
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
					} else if (mainWindow.callState === LinphoneEnums.CallState.OutgoingInit || mainWindow.callState === LinphoneEnums.CallState.End) {
						connectedCallButtons.visible = false
						bottomButtonsLayout.layoutDirection = Qt.LeftToRight
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
					onClicked: mainWindow.endCall(mainWindow.call)
				}
				RowLayout {
					id: connectedCallButtons
					visible: false
					Layout.row: 0
					Layout.column: 1
					BottomButton {
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
					BottomButton {
						id: moreOptionsButton
						checkable: true
						enabledIcon: AppIcons.verticalDots
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						onPressed: {
							moreOptionsMenu.visible = !moreOptionsMenu.visible
						}
					}
					Popup {
						id: moreOptionsMenu
						x: moreOptionsButton.x
						y: moreOptionsButton.y - height
						padding: 20 * DefaultStyle.dp

						// closePolicy: Control.Popup.CloseOnEscape
						onAboutToHide: moreOptionsButton.checked = false
						contentItem: ColumnLayout {
							id: optionsList
							spacing: 10 * DefaultStyle.dp
							
							Control.Button {
								id: callListButton
								Layout.fillWidth: true
								background: Item {
									visible: false
								}
								contentItem: RowLayout {
									Image {
										width: 24 * DefaultStyle.dp
										height: 24 * DefaultStyle.dp
										source: AppIcons.callList
									}
									Text {
										text: qsTr("Liste d'appel")
									}
								}
								onClicked: {
									rightPanel.visible = true
									rightPanel.replace(callsListPanel)
									moreOptionsMenu.close()
								}
							}
							Control.Button {
								id: dialerButton
								Layout.fillWidth: true
								background: Item {
									visible: false
								}
								contentItem: RowLayout {
									Image {
										width: 24 * DefaultStyle.dp
										height: 24 * DefaultStyle.dp
										source: AppIcons.dialer
									}
									Text {
										text: qsTr("Dialer")
									}
								}
								onClicked: {
									rightPanel.visible = true
									rightPanel.replace(dialerPanel)
									moreOptionsMenu.close()
								}
							}
							Control.Button {
								id: speakerButton
								Layout.fillWidth: true
								checkable: true
								background: Item {
									visible: false
								}
								contentItem: RowLayout {
									Image {
										width: 24 * DefaultStyle.dp
										height: 24 * DefaultStyle.dp
										source: mainWindow.call.core.speakerMuted ? AppIcons.speakerSlash : AppIcons.speaker
									}
									Text {
										text: mainWindow.call.core.speakerMuted ? qsTr("Activer le son") : qsTr("Désactiver le son")
									}

								}
								onClicked: {
									mainWindow.call.core.lSetSpeakerMuted(!mainWindow.call.core.speakerMuted)
								}
							}
						}
					}
				}
			}
		}
	}
	Sticker{
		height: 100 * DefaultStyle.dp
		width: 100 * DefaultStyle.dp
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		visible: mainWindow.call.core.cameraEnabled
		AccountProxy{
			id: accounts
		}
		account: accounts.defaultAccount
	}
}
