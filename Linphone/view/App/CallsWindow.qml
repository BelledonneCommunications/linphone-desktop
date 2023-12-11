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

	property CallGui call

	property int callsCount: 0
	onCallsCountChanged: console.log("calls count", callsCount)

	property var peerName: UtilsCpp.getDisplayName(call.core.peerAddress)
	property string peerNameText: peerName ? peerName.value : ""
	
	// TODO : remove this, for debug only
	property var callState: call && call.core.state
	onCallStateChanged: {
		console.log("State:", callState)
		if (callState === LinphoneEnums.CallState.Error || callState === LinphoneEnums.CallState.End) {
			endCall()
		}
	}
	onClosing: {
		endCall()
	}

	Timer {
		id: autoCloseWindow
		interval: 2000
		onTriggered: {
			UtilsCpp.closeCallsWindow()
		} 
	}
	
	function endCall() {
		console.log("remaining calls before ending", mainWindow.callsCount)
		callStatusText.text = qsTr("End of the call")
		if (call) call.core.lTerminate()
		if (callsCount === 1) {
			bottomButtonsLayout.setButtonsEnabled(false)
			autoCloseWindow.restart()
		}
	}
	
	CallProxy{
		id: callList
		onCurrentCallChanged: {
			console.log("Current call changed:"+currentCall)
			if(currentCall) mainWindow.call = currentCall
		}
	}

	component BottomButton : Button {
		required property string enabledIcon
		property string disabledIcon
		id: bottomButton
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
	Control.Popup {
		id: waitingPopup
		visible: mainWindow.call.core.transferState === LinphoneEnums.CallState.OutgoingInit
					|| mainWindow.call.core.transferState === LinphoneEnums.CallState.OutgoingProgress
					|| mainWindow.call.core.transferState === LinphoneEnums.CallState.OutgoingRinging || false
		modal: true
		closePolicy: Control.Popup.NoAutoClose
		anchors.centerIn: parent
		padding: 20 * DefaultStyle.dp
		background: Item {

			anchors.fill: parent
			Rectangle {
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				height: parent.height + 2
				color: DefaultStyle.main1_500_main
				radius: 15 * DefaultStyle.dp
			}
			Rectangle {
				id: mainBackground
				anchors.fill: parent
				radius: 15 * DefaultStyle.dp
			}
		}
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
	Control.Popup {
		id: transferErrorPopup
		visible: mainWindow.call.core.transferState === LinphoneEnums.CallState.Error
		onVisibleChanged: if (visible) autoClosePopup.restart()
		closePolicy: Control.Popup.NoAutoClose
		x : parent.x + parent.width - width
		y : parent.y + parent.height - height
		rightMargin: 20 * DefaultStyle.dp
		bottomMargin: 20 * DefaultStyle.dp
		padding: 20 * DefaultStyle.dp
		background: Item {
			anchors.fill: parent
			Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				height: parent.height + 2 * DefaultStyle.dp
				color: DefaultStyle.danger_500main
			}
			Rectangle {
				id: transferErrorBackground
				anchors.fill: parent
			}
			MultiEffect {
				anchors.fill: transferErrorBackground
				shadowEnabled: true
				shadowColor: DefaultStyle.grey_900
				shadowBlur: 1
				// shadowOpacity: 0.1
			}
		}
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
						image.source: (mainWindow.call.core.state === LinphoneEnums.CallState.Paused
							|| mainWindow.callState === LinphoneEnums.CallState.PausedByRemote)
							? AppIcons.pause
							: (mainWindow.callState === LinphoneEnums.CallState.End
							|| mainWindow.callState === LinphoneEnums.CallState.Released)
								? AppIcons.endCall
								: mainWindow.call.core.dir === LinphoneEnums.CallDir.Outgoing
									? AppIcons.outgoingCall
									: AppIcons.incomingCall
						colorizationColor: mainWindow.callState === LinphoneEnums.CallState.Paused
							|| mainWindow.callState === LinphoneEnums.CallState.PausedByRemote || mainWindow.callState === LinphoneEnums.CallState.End
							|| mainWindow.callState === LinphoneEnums.CallState.Released ? DefaultStyle.danger_500main : undefined
					}
					Text {
						id: callStatusText
						text: (mainWindow.callState === LinphoneEnums.CallState.End  || mainWindow.callState === LinphoneEnums.CallState.Released)
							? qsTr("End of the call")
							: (mainWindow.callState === LinphoneEnums.CallState.Paused  || mainWindow.callState === LinphoneEnums.CallState.PausedByRemote)
								? qsTr("Appel mis en pause")
								: EnumsToStringCpp.dirToString(mainWindow.call.core.dir) + qsTr(" call")
						color: DefaultStyle.grey_0
						font {
							pixelSize: 22 * DefaultStyle.dp
							weight: 800 * DefaultStyle.dp
						}
					}
					Rectangle {
						visible: mainWindow.callState === LinphoneEnums.CallState.Connected
								|| mainWindow.callState === LinphoneEnums.CallState.StreamsRunning
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
						visible: mainWindow.callState === LinphoneEnums.CallState.Connected
								|| mainWindow.callState === LinphoneEnums.CallState.StreamsRunning
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
						color: DefaultStyle.grey_600 * DefaultStyle.dp
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
									if (mainWindow.callState === LinphoneEnums.CallState.Error) {
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
									id: secondsTimer
									interval: 1000
									repeat: true
									onTriggered: waitingTime.seconds += 1
								}
								ColumnLayout {
									anchors.horizontalCenter: parent.horizontalCenter
									anchors.top: parent.top
									anchors.topMargin: 30 * DefaultStyle.dp
									visible: mainWindow.callState == LinphoneEnums.CallState.OutgoingInit
											|| mainWindow.callState == LinphoneEnums.CallState.OutgoingProgress
											|| mainWindow.callState == LinphoneEnums.CallState.OutgoingRinging
											|| mainWindow.callState == LinphoneEnums.CallState.OutgoingEarlyMedia
											|| mainWindow.callState == LinphoneEnums.CallState.IncomingReceived
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
										font.pointSize: 30 * DefaultStyle.dp
										Component.onCompleted: {
											secondsTimer.restart()
										}
									}
								}
								ColumnLayout {
									anchors.centerIn: parent
									spacing: 2 * DefaultStyle.dp
									Avatar {
										Layout.alignment: Qt.AlignCenter
										// TODO : remove username when friend list ready
										address: mainWindow.peerNameText
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
					headerContent: StackLayout {
						currentIndex: rightPanel.currentIndex
						anchors.verticalCenter: parent.verticalCenter
						Text {
							color: DefaultStyle.main2_700
							text: qsTr("Transfert d'appel")
							font.bold: true
						}
						Text {
							color: DefaultStyle.main2_700
							text: qsTr("Dialer")
							font.bold: true
						}
					}
					contentItem: StackLayout {
						currentIndex: rightPanel.currentIndex
						ContactsList {
							Layout.fillWidth: true
							Layout.fillHeight: true
							sideMargin: 10 * DefaultStyle.dp
							topMargin: 15 * DefaultStyle.dp
							groupCallVisible: false
							searchBarColor: DefaultStyle.grey_0
							searchBarBorderColor: DefaultStyle.grey_200
							onCallButtonPressed: (address) => {
								mainWindow.call.core.lTransferCall(address)
							}
						}
						ColumnLayout {
							Layout.fillWidth: true
							Layout.fillHeight: true
							SearchBar {
								id: dialerTextInput
								Layout.fillWidth: true
								// Layout.maximumWidth: mainItem.width
								color: DefaultStyle.grey_0
								borderColor: DefaultStyle.grey_200
								placeholderText: ""
								numericPad: numPad
								Component.onCompleted: numericPad.visible = true
								numericPadButton.visible: false
							}
							Item {
								Component.onCompleted: console.log("num pad", x, y, width, height)
								Layout.fillWidth: true
								Layout.preferredHeight: numPad.height
								Layout.fillHeight: numPad.height
								Layout.alignment: Qt.AlignBottom
								visible: false
								onVisibleChanged: {
									console.log("visible cvhanged", visible)
									if (visible) numPad.open()
									else numPad.close()
								}
								NumericPad {
									id: numPad
									width: parent.width
									visible: parent.visible
									closeButtonVisible: false
									onVisibleChanged: {
									console.log("visible numpad", visible, parent.visible)
									}
									onOpened: console.log("open")
									onClosed: console.log("close")
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
				Connections {
					target: mainWindow
					onCallStateChanged: if (mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning) {
						bottomButtonsLayout.layoutDirection = Qt.RightToLeft
						connectedCallButtons.visible = true
					}
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
					onClicked: mainWindow.endCall()
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
						enabled: mainWindow.callState != LinphoneEnums.CallState.PausedByRemote
						enabledIcon: enabled && checked ? AppIcons.play : AppIcons.pause
						checked: mainWindow.call && (mainWindow.call.callState === LinphoneEnums.CallState.Paused
								|| mainWindow.call.callState === LinphoneEnums.CallState.PausedByRemote) || false
						onClicked: mainWindow.call.core.lSetPaused(!mainWindow.call.core.paused)
					}
					BottomButton {
						id: transferCallButton
						enabledIcon: AppIcons.transferCall
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						onClicked: {
							rightPanel.visible = true
							rightPanel.currentIndex = 0
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
						onCheckedChanged: {
							if (checked) moreOptionsMenu.open()
							else moreOptionsMenu.close()
						}
					}
					Popup {
						id: moreOptionsMenu
						x: moreOptionsButton.x
						y: moreOptionsButton.y - height
						padding: 20 * DefaultStyle.dp

						closePolicy: Control.Popup.CloseOnEscape
						onClosed: moreOptionsButton.checked = false

						Connections {
							target: rightPanel
							onVisibleChanged: if (!rightPanel.visible) moreOptionsMenu.close()
						}

						contentItem: ColumnLayout {
							id: optionsList
							spacing: 10 * DefaultStyle.dp
							
							Control.Button {
								id: dialerButton
								// width: 150
								Layout.fillWidth: true
								height: 32 * DefaultStyle.dp
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
									rightPanel.currentIndex = 1
									moreOptionsMenu.close()
								}
							}
							Control.Button {
								id: speakerButton
								Layout.fillWidth: true
								height: 32 * DefaultStyle.dp
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
