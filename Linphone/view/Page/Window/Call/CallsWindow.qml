import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Basic as Control
import Linphone
import EnumsToStringCpp
import UtilsCpp
import SettingsCpp
import DesktopToolsCpp

AbstractWindow {
    id: mainWindow
	flags: Qt.Window
	// modality: Qt.WindowModal

	property CallGui call

	property ConferenceGui conference: call && call.core.conference || null

	property int conferenceLayout: call && call.core.conferenceVideoLayout || 0
	property bool localVideoEnabled: call && call.core.localVideoEnabled
	property bool remoteVideoEnabled: call && call.core.remoteVideoEnabled

	property bool callTerminatedByUser: false
	property var callState: call ? call.core.state : LinphoneEnums.CallState.Idle
	property var transferState: call && call.core.transferState

	onCallStateChanged: {
		if (callState === LinphoneEnums.CallState.Connected) {
			if (middleItemStackView.currentItem.objectName != "inCallItem") {
				middleItemStackView.replace(inCallItem)
				bottomButtonsLayout.visible = true
			}
			if(call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp && !mainWindow.conference && (!call.core.tokenVerified || call.core.isMismatch)) {
				zrtpValidation.open()
			}
		}
		else if (callState === LinphoneEnums.CallState.Error || callState === LinphoneEnums.CallState.End) {
			zrtpValidation.close()
			callEnded(call)
		}
	}

	onTransferStateChanged: {
		console.log("Transfer state:", transferState)
		if (mainWindow.transferState === LinphoneEnums.CallState.OutgoingInit) {
			var callsWin = UtilsCpp.getCallsWindow()
			if (!callsWin) return
			callsWin.showLoadingPopup(qsTr("Transfert en cours, veuillez patienter"))
		}
		else if (mainWindow.transferState === LinphoneEnums.CallState.Error
		|| mainWindow.transferState === LinphoneEnums.CallState.End
		|| mainWindow.transferState === LinphoneEnums.CallState.Released
		|| mainWindow.transferState === LinphoneEnums.CallState.Connected) {
			var callsWin = UtilsCpp.getCallsWindow()
			callsWin.closeLoadingPopup()
			if (transferState === LinphoneEnums.CallState.Error) UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("Le transfert d'appel a échoué"), false, mainWindow)
			else if (transferState === LinphoneEnums.CallState.Connected){
				var mainWin = UtilsCpp.getMainWindow()
				UtilsCpp.smartShowWindow(mainWin)
				mainWin.transferCallSucceed()
			}
		} 
	}
	onClosing: (close) => {
		DesktopToolsCpp.screenSaverStatus = true
		if (callsModel.haveCall) {
			close.accepted = false
			terminateAllCallsDialog.open()
		}
		if (middleItemStackView.currentItem.objectName === "waitingRoom") middleItemStackView.replace(inCallItem)
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
	
	function endCall(callToFinish) {
		if (callToFinish) callToFinish.core.lTerminate()
		// var mainWin = UtilsCpp.getMainWindow()
		// mainWin.goToCallHistory()
	}
	function callEnded(call){
		if (call.core.state === LinphoneEnums.CallState.Error) {
			middleItemStackView.replace(inCallItem)
		}
		if (!callsModel.haveCall) {
			if (call && call.core.isConference) UtilsCpp.closeCallsWindow()
			else {
				bottomButtonsLayout.setButtonsEnabled(false)
				autoCloseWindow.restart()
			}
		} else {
			mainWindow.call = callsModel.currentCall
		}
	}

	signal setUpConferenceRequested(ConferenceInfoGui conferenceInfo)
	function setupConference(conferenceInfo) {
		middleItemStackView.replace(waitingRoom)
		setUpConferenceRequested(conferenceInfo)
	}

	function joinConference(uri, options) {
		if (uri.length === 0) UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("La conférence n'a pas pu démarrer en raison d'une erreur d'uri."), mainWindow)
		else {
			UtilsCpp.createCall(uri, options)
		}
	}
	function cancelJoinConference() {
		if (!callsModel.haveCall) {
			UtilsCpp.closeCallsWindow()
		} else {
			mainWindow.call = callsModel.currentCall
		}
		middleItemStackView.replace(inCallItem)
	}
	
	Connections {
		enabled: !!call
		target: call && call.core
		function onSecurityUpdated() {
			if (call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp) {
				if (call.core.tokenVerified) {
					zrtpValidation.close()
					zrtpValidationToast.open()
				} else {
					zrtpValidation.open()
				}
			} else {
				zrtpValidation.close()
			}
		}
		function onTokenVerified() {
			if (!zrtpValidation.isTokenVerified) {
				zrtpValidation.securityError = true
			} else zrtpValidation.close()
		}
	}
	
	Timer {
		id: autoCloseWindow
		interval: 3000
		onTriggered: {
			UtilsCpp.closeCallsWindow()
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
		sourceModel: AppCpp.calls
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
	ZrtpAuthenticationDialog {
		id: zrtpValidation
		call: mainWindow.call
		modal: true
	}
	Timer {
		id: autoCloseZrtpToast
		interval: 4000
		onTriggered: {
			zrtpValidationToast.y = -zrtpValidationToast.height*2
		}
	}
	Control.Control {
		id: zrtpValidationToast
		// width: 269 * DefaultStyle.dp
		y: -height*2
		z: 1
		topPadding: 8 * DefaultStyle.dp
		bottomPadding: 8 * DefaultStyle.dp
		leftPadding: 50 * DefaultStyle.dp
		rightPadding: 50 * DefaultStyle.dp
		anchors.horizontalCenter: parent.horizontalCenter
		clip: true
		function open() {
			y = headerItem.height/2
			autoCloseZrtpToast.restart()
		}
		Behavior on y {NumberAnimation {duration: 1000}}
		background: Rectangle {
			anchors.fill: parent
			color: DefaultStyle.grey_0
			border.color: DefaultStyle.info_500_main
			border.width:  1 * DefaultStyle.dp
			radius: 50 * DefaultStyle.dp
		}
		contentItem: RowLayout {
			// anchors.centerIn: parent
			Image {
				source: AppIcons.trusted
				Layout.preferredWidth: 24 * DefaultStyle.dp
				Layout.preferredHeight: 24 * DefaultStyle.dp
				fillMode: Image.PreserveAspectFit
				Layout.fillWidth: true
			}
			Text {
				color: DefaultStyle.info_500_main
				text: qsTr("Appareil vérifié")
				Layout.fillWidth: true
				font {
					pixelSize: 14 * DefaultStyle.dp
				}
			}
		}
	}

/************************* CONTENT ********************************/
	
	Rectangle {
		anchors.fill: parent
		color: DefaultStyle.grey_900
		ColumnLayout {
			anchors.fill: parent
			spacing: 10 * DefaultStyle.dp
			anchors.bottomMargin: 10 * DefaultStyle.dp
			anchors.topMargin: 10 * DefaultStyle.dp
			Item {
				id: headerItem
				Layout.margins: 10 * DefaultStyle.dp
				Layout.leftMargin: 20 * DefaultStyle.dp
				Layout.fillWidth: true
				Layout.minimumHeight: 25 * DefaultStyle.dp
				RowLayout {
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					spacing: 10 * DefaultStyle.dp
					RowLayout {
						spacing: 10 * DefaultStyle.dp
						EffectImage {
							id: callStatusIcon
							Layout.preferredWidth: 30 * DefaultStyle.dp
							Layout.preferredHeight: 30 * DefaultStyle.dp
							// TODO : change with broadcast or meeting icon when available
							imageSource: !mainWindow.call
								? AppIcons.meeting
								: (mainWindow.callState === LinphoneEnums.CallState.End
									|| mainWindow.callState === LinphoneEnums.CallState.Released)
									? AppIcons.endCall
									: (mainWindow.callState === LinphoneEnums.CallState.Paused
									|| mainWindow.callState === LinphoneEnums.CallState.PausedByRemote)
										? AppIcons.pause
										: mainWindow.conference
											? AppIcons.usersThree
											: mainWindow.call.core.dir === LinphoneEnums.CallDir.Outgoing
												? AppIcons.arrowUpRight
												: AppIcons.arrowDownLeft
							colorizationColor: !mainWindow.call || mainWindow.call.core.paused || mainWindow.callState === LinphoneEnums.CallState.Paused
								|| mainWindow.callState === LinphoneEnums.CallState.PausedByRemote || mainWindow.callState === LinphoneEnums.CallState.End
								|| mainWindow.callState === LinphoneEnums.CallState.Released || mainWindow.conference 
								? DefaultStyle.danger_500main
								: mainWindow.call.core.dir === LinphoneEnums.CallDir.Outgoing
									? DefaultStyle.info_500_main
									: DefaultStyle.success_500main
							onColorizationColorChanged: {
								callStatusIcon.active = !callStatusIcon.active
								callStatusIcon.active = !callStatusIcon.active
							}
						}
						ColumnLayout {
							spacing: 6 * DefaultStyle.dp
							RowLayout {
								spacing: 10 * DefaultStyle.dp
								Text {
									id: callStatusText
									property string remoteName: mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning
										? mainWindow.call.core.remoteName
										: EnumsToStringCpp.dirToString(mainWindow.call.core.dir) + qsTr(" call")
									text: (mainWindow.callState === LinphoneEnums.CallState.End  || mainWindow.callState === LinphoneEnums.CallState.Released)
										? qsTr("Fin d'appel")
										: mainWindow.call && (mainWindow.call.core.paused
										|| (mainWindow.callState === LinphoneEnums.CallState.Paused
										|| mainWindow.callState === LinphoneEnums.CallState.PausedByRemote))
											? (mainWindow.conference ? qsTr('Réunion mise ') : qsTr('Appel mis')) + qsTr(" en pause")
											: mainWindow.conference
												? mainWindow.conference.core.subject
												: remoteName
									color: DefaultStyle.grey_0
									font {
										pixelSize: 22 * DefaultStyle.dp
										weight: 800 * DefaultStyle.dp
									}
								}
								Rectangle {
									visible: mainWindow.call && (mainWindow.callState === LinphoneEnums.CallState.Connected
											|| mainWindow.callState === LinphoneEnums.CallState.StreamsRunning)
									Layout.fillHeight: true
									Layout.topMargin: 10 * DefaultStyle.dp
									Layout.bottomMargin: 2 * DefaultStyle.dp
									Layout.preferredWidth: 2 * DefaultStyle.dp
									color: DefaultStyle.grey_0
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
									Layout.leftMargin: 14 * DefaultStyle.dp
									id: conferenceDate
									text: mainWindow.conferenceInfo ? mainWindow.conferenceInfo.core.getStartEndDateString() : ""
									color: DefaultStyle.grey_0
									font {
										pixelSize: 14 * DefaultStyle.dp
										weight: 400 * DefaultStyle.dp
										capitalization: Font.Capitalize
									}
								}
							}
							RowLayout {
								spacing: 5 * DefaultStyle.dp
								visible: mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning
								BusyIndicator  {
									visible: mainWindow.call && mainWindow.callState != LinphoneEnums.CallState.Connected && mainWindow.callState != LinphoneEnums.CallState.StreamsRunning
									Layout.preferredWidth: 15 * DefaultStyle.dp
									Layout.preferredHeight: 15 * DefaultStyle.dp
									indicatorColor: DefaultStyle.grey_0
								}
								EffectImage {
									Layout.preferredWidth: 15 * DefaultStyle.dp
									Layout.preferredHeight: 15 * DefaultStyle.dp
									colorizationColor: mainWindow.call 
										? mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Srtp
											? DefaultStyle.info_500_main
											: mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp 
												? mainWindow.call.core.isMismatch || !mainWindow.call.core.tokenVerified
													? DefaultStyle.warning_600
													: DefaultStyle.info_500_main
												: DefaultStyle.grey_0
										: "transparent"
									visible: mainWindow.call && mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning
									imageSource: mainWindow.call 
									? mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Srtp

										? AppIcons.lockSimple
										: mainWindow.call && mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp 
											? mainWindow.call.core.isMismatch || !mainWindow.call.core.tokenVerified
												? AppIcons.warningCircle
												: AppIcons.lockKey
											: AppIcons.lockSimpleOpen
									: ""
								}
								Text {
									text: mainWindow.call && mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning
									? mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Srtp
										? qsTr("Appel chiffré de point à point")
										: mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp 
											? mainWindow.call.core.isMismatch || !mainWindow.call.core.tokenVerified
												? qsTr("Vérification nécessaire")
												: qsTr("Appel chiffré de bout en bout")
											: qsTr("Appel non chiffré")
									: qsTr("En attente de chiffrement")
									color: mainWindow.call && mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning
									? mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Srtp
										? DefaultStyle.info_500_main
										: mainWindow.call.core.encryption === LinphoneEnums.MediaEncryption.Zrtp 
											? mainWindow.call.core.isMismatch || !mainWindow.call.core.tokenVerified
												? DefaultStyle.warning_600
												: DefaultStyle.info_500_main
											: DefaultStyle.grey_0
									: DefaultStyle.grey_0
									font {
										pixelSize: 12 * DefaultStyle.dp
										weight: 400 * DefaultStyle.dp
									}
									MouseArea {
										anchors.fill: parent
										hoverEnabled: true
										cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
										onClicked: {
											rightPanel.visible = true
											rightPanel.replace(encryptionPanel)
										}
									}
								}
								Item {
									Layout.fillWidth: true
								}
							}
						}
						
					}
					Item {
						Layout.fillWidth: true
					}
					EffectImage {
						Layout.preferredWidth: 32 * DefaultStyle.dp
						Layout.preferredHeight: 32 * DefaultStyle.dp
						Layout.rightMargin: 30 * DefaultStyle.dp
						property int quality: mainWindow.call ? mainWindow.call.core.quality : 0
						imageSource: quality >= 4
							? AppIcons.cellSignalFull
							: quality >= 3
								? AppIcons.cellSignalMedium
								: quality >= 2
									? AppIcons.cellSignalLow
									: AppIcons.cellSignalNone
						colorizationColor: DefaultStyle.grey_0
						MouseArea {
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
							onClicked: {
								if (rightPanel.visible && rightPanel.contentStackView.currentItem.objectName === "statsPanel") rightPanel.visible = false
								else {
									rightPanel.visible = true
									rightPanel.replace(statsPanel)
								}
							}
						}
					}
				}

				Control.Control {
					visible: mainWindow.call
					? !!mainWindow.conference
						? mainWindow.conference.core.isRecording
						: (mainWindow.call.core.recording || mainWindow.call.core.remoteRecording)
					: false
					anchors.centerIn: parent
					leftPadding: 14 * DefaultStyle.dp
					rightPadding: 14 * DefaultStyle.dp
					topPadding: 6 * DefaultStyle.dp
					bottomPadding: 6 * DefaultStyle.dp
					background: Rectangle {
						anchors.fill: parent
						color: DefaultStyle.grey_500
						radius: 10 * DefaultStyle.dp
					}
					contentItem: RowLayout {
						spacing: 85 * DefaultStyle.dp
						RowLayout {
							spacing: 15 * DefaultStyle.dp
							EffectImage {
								imageSource: AppIcons.recordFill
								colorizationColor: DefaultStyle.danger_500main
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
							}
							Text {
								color: DefaultStyle.danger_500main
								font.pixelSize: 14 * DefaultStyle.dp
								text: mainWindow.call
									? mainWindow.call.core.recording 
										? mainWindow.conference ? qsTr("Vous enregistrez la réunion") : qsTr("Vous enregistrez l'appel") 
										: mainWindow.conference ? qsTr("Un participant enregistre la réunion") : qsTr("Votre correspondant enregistre l'appel")
									: ""
							}
						}
						Button {
							visible: mainWindow.call && mainWindow.call.core.recording
							text: qsTr("Arrêter l'enregistrement")
							onPressed: mainWindow.call.core.lStopRecording()
						}
					}
				}
			
			}
			
			RowLayout {
				Layout.fillWidth: true
				Layout.fillHeight: true
				spacing: 23 * DefaultStyle.dp
				Control.StackView {
					id: middleItemStackView
					initialItem: inCallItem
					Layout.fillWidth: true
					Layout.fillHeight: true
				}
				CallSettingsPanel {
					id: rightPanel
					Layout.fillHeight: true
					Layout.rightMargin: 20 * DefaultStyle.dp
					Layout.preferredWidth: 393 * DefaultStyle.dp
					Layout.topMargin: 10 * DefaultStyle.dp
					property int currentIndex: 0
					visible: false
					function replace(id) {
						rightPanel.customHeaderButtons = null
						contentStackView.replace(id, Control.StackView.Immediate)
					}
					headerStack.currentIndex: 0
					contentStackView.initialItem: callsListPanel
					headerValidateButtonText: qsTr("Ajouter")

					Item {
						id: numericPadContainer
						anchors.bottom: parent.bottom
						anchors.left: parent.left
						anchors.right: parent.right
						height: childrenRect.height
					}
				}
			}
			
		
			Component {
				id: callTransferPanel
				NewCallForm {
					id: newCallForm
					Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Transférer %1 à :").arg(mainWindow.call.core.remoteName)
					Keys.onPressed: (event)=> {
						if (event.key == Qt.Key_Escape) {
							rightPanel.visible = false
							event.accepted = true;
						}
					}
					groupCallVisible: false
					displayCurrentCalls: true
					searchBarColor: DefaultStyle.grey_0
					searchBarBorderColor: DefaultStyle.grey_200
					onContactClicked: (contact) => {
						var callsWin = UtilsCpp.getCallsWindow()
						if (contact) callsWin.showConfirmationLambdaPopup(
							qsTr("Confirmer le transfert ?"),
							qsTr("Vous allez transférer %1 à %2.").arg(mainWindow.call.core.remoteName).arg(contact.core.displayName),
							"",
							function (confirmed) {
								if (confirmed) {
									mainWindow.transferCallToContact(mainWindow.call, contact, newCallForm)
								}
							}
						)
					}
					onTransferCallToAnotherRequested: (dest) => {
						var callsWin = UtilsCpp.getCallsWindow()
						console.log("transfer to", dest)
						callsWin.showConfirmationLambdaPopup(
							qsTr("Confirmer le transfert ?"),
							qsTr("Vous allez transférer %1 à %2.").arg(mainWindow.call.core.remoteName).arg(dest.core.remoteName),
							"",
							function (confirmed) {
								if (confirmed) {
									mainWindow.call.core.lTransferCallToAnother(dest.core.remoteAddress)
								}
							}
						)
					}
					numPadPopup: numPadPopup

					NumericPadPopup {
						id: numPadPopup
						parent: numericPadContainer
						width: parent.width
						roundedBottom: true
						lastRowVisible: false
						visible: false
						leftPadding: 40 * DefaultStyle.dp
						rightPadding: 40 * DefaultStyle.dp
						topPadding: 41 * DefaultStyle.dp
						bottomPadding: 18 * DefaultStyle.dp
						Component.onCompleted: parent.height = height
					}
				}
			}
			Component {
				id: newCallPanel
				NewCallForm {
					id: newCallForm
					objectName: "newCallPanel"
					Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Nouvel appel")
					groupCallVisible: false
					searchBarColor: DefaultStyle.grey_0
					searchBarBorderColor: DefaultStyle.grey_200
					numPadPopup: numericPad
					onContactClicked: (contact) => {
						rightPanel.visible = false
						mainWindow.startCallWithContact(contact, false, rightPanel)
					}
					
					NumericPadPopup {
						id: numericPad
						width: parent.width
						parent: numericPadContainer
						roundedBottom: true
						visible: newCallForm.searchBar.numericPadButton.checked
						leftPadding: 40 * DefaultStyle.dp
						rightPadding: 40 * DefaultStyle.dp
						topPadding: 41 * DefaultStyle.dp
						bottomPadding: 18 * DefaultStyle.dp
						onLaunchCall: {
							rightPanel.visible = false
							UtilsCpp.createCall(newCallForm.searchBar.text)
						}
						Component.onCompleted: parent.height = height
					}
				}
			}
			Component {
				id: dialerPanel
				ColumnLayout {
					id: dialerPanelContent
					Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Dialer")
					spacing: 0
					Keys.onPressed: (event)=> {
						if (event.key == Qt.Key_Escape) {
							rightPanel.visible = false
							event.accepted = true;
						}
					}
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
						numericPadPopup: numPadPopup
						numericPadButton.visible: false
						enabled: false
					}
					
					NumericPadPopup {
						id: numPadPopup
						width: parent.width
						parent: numericPadContainer
						closeButtonVisible: false
						roundedBottom: true
						visible: dialerPanelContent.visible
						currentCall: callsModel.currentCall
						lastRowVisible: false
						leftPadding: 40 * DefaultStyle.dp
						rightPadding: 40 * DefaultStyle.dp
						topPadding: 41 * DefaultStyle.dp
						bottomPadding: 18 * DefaultStyle.dp
						onLaunchCall: {
							UtilsCpp.createCall(dialerTextInput.text)
						}
						Component.onCompleted: parent.height = height
					}
				}
			}
			Component {
				id: changeLayoutPanel
				ChangeLayoutForm {
					Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Modifier la disposition")
					Keys.onPressed: (event)=> {
						if (event.key == Qt.Key_Escape) {
							rightPanel.visible = false
							event.accepted = true;
						}
					}
					call: mainWindow.call
					onChangeLayoutRequested: (index) => {
						mainWindow.changeLayout(index)
					}
				}
			}
			Component {
				id: callsListPanel
				ColumnLayout {
					Control.StackView.onActivated: {
						rightPanel.headerTitleText = qsTr("Liste d'appel")
						rightPanel.customHeaderButtons = mergeCallPopupButton.createObject(rightPanel)
					}
					Keys.onPressed: (event)=> {
						if (event.key == Qt.Key_Escape) {
							rightPanel.visible = false
							event.accepted = true;
						}
					}
					spacing: 0
					Component {
						id: mergeCallPopupButton
						PopupButton {
							visible: callsModel.count >= 2
							id: popupbutton
							popup.contentItem: Button {
								background: Item{}
								contentItem: RowLayout {
									spacing: 5 * DefaultStyle.dp
									EffectImage {
										colorizationColor: DefaultStyle.main2_600
										imageSource: AppIcons.arrowsMerge
										Layout.preferredWidth: 32 * DefaultStyle.dp
										Layout.preferredHeight: 32 * DefaultStyle.dp
									}
									Text {
										text: qsTr("Merger tous les appels")
										font.pixelSize: 14 * DefaultStyle.dp
									}
								}
								onClicked: {
									callsModel.lMergeAll()
									popupbutton.close()
								}
							}
						}
					}
					RoundedPane {
						Layout.fillWidth: true
						Layout.maximumHeight: rightPanel.height
						visible: callList.contentHeight > 0
						leftPadding: 16 * DefaultStyle.dp
						rightPadding: 6 * DefaultStyle.dp
						topPadding: 15 * DefaultStyle.dp
						bottomPadding: 16 * DefaultStyle.dp

						Layout.topMargin: 15 * DefaultStyle.dp
						Layout.bottomMargin: 16 * DefaultStyle.dp
						Layout.leftMargin: 16 * DefaultStyle.dp
						Layout.rightMargin: 16 * DefaultStyle.dp
						
						contentItem: CallListView {
							id: callList
						}
					}
					Item {
						Layout.fillHeight: true
					}
				}
			}
			Component {
				id: settingsPanel
				Item {
					Control.StackView.onActivated: {
						rightPanel.headerTitleText = qsTr("Paramètres")
					}
					Keys.onPressed: (event)=> {
						if (event.key == Qt.Key_Escape) {
							rightPanel.visible = false
							event.accepted = true;
						}
					}
					MultimediaSettings {
						id: inSettingsPanel
						call: mainWindow.call
						anchors.fill: parent
						anchors.topMargin: 16 * DefaultStyle.dp
						anchors.bottomMargin: 16 * DefaultStyle.dp
						anchors.leftMargin: 17 * DefaultStyle.dp
						anchors.rightMargin: 17 * DefaultStyle.dp
					}
				}
			}
			Component {
				id: screencastPanel
				Item {
					Control.StackView.onActivated: rightPanel.headerTitleText = qsTr("Partage de votre écran")
					Keys.onPressed: (event)=> {
						if (event.key == Qt.Key_Escape) {
							rightPanel.visible = false
							event.accepted = true;
						}
					}
					ScreencastSettings {
						anchors.fill: parent
						anchors.topMargin: 16 * DefaultStyle.dp
						anchors.bottomMargin: 16 * DefaultStyle.dp
						anchors.leftMargin: 17 * DefaultStyle.dp
						anchors.rightMargin: 17 * DefaultStyle.dp
						call: mainWindow.call
					}
				}
			}
			Component {
				id: participantListPanel
				Item {
					objectName: "participantListPanel"
					Keys.onPressed: (event)=> {
						if (event.key == Qt.Key_Escape) {
							rightPanel.visible = false
							event.accepted = true;
						}
					}
					Control.StackView {
						id: participantsStack
						anchors.fill: parent
						anchors.bottomMargin: 16 * DefaultStyle.dp
						anchors.leftMargin: 17 * DefaultStyle.dp
						anchors.rightMargin: 17 * DefaultStyle.dp
						initialItem: participantListComp
						onCurrentItemChanged: rightPanel.headerStack.currentIndex = currentItem.Control.StackView.index
						property list<string> selectedParticipants
						signal participantAdded()

						Connections {
							target: rightPanel
							function onReturnRequested(){ participantsStack.pop()}
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
												UtilsCpp.copyToClipboard(mainWindow.call.core.remoteAddress)
												showInformationPopup(qsTr("Copié"), qsTr("Le lien de la réunion a été copié dans le presse-papier"), true)
											}
										}
									}
								}
								Control.StackView.onActivated: {
									rightPanel.customHeaderButtons = headerbutton.createObject(rightPanel)
									rightPanel.headerTitleText = qsTr("Participants (%1)").arg(count)
								}
								call: mainWindow.call
								onAddParticipantRequested: participantsStack.push(addParticipantComp)
								onCountChanged: {
									rightPanel.headerTitleText = qsTr("Participants (%1)").arg(count)
								}
								Connections {
									target: participantsStack
									function onCurrentItemChanged() {
										if (participantsStack.currentItem == participantList) rightPanel.headerTitleText = qsTr("Participants (%1)").arg(participantList.count)
									}
								}
								Connections {
									target: rightPanel
									function onValidateRequested() {
										participantList.model.addAddresses(participantsStack.selectedParticipants)
										participantsStack.pop()
										participantsStack.participantAdded()
									}
								}
							}
						}
						Component {
							id: addParticipantComp
							AddParticipantsForm {
								id: addParticipantLayout
								searchBarColor: DefaultStyle.grey_0
								searchBarBorderColor: DefaultStyle.grey_200
								onSelectedParticipantsCountChanged: {
									rightPanel.headerSubtitleText = qsTr("%1 participant%2 sélectionné%2").arg(selectedParticipantsCount).arg(selectedParticipantsCount > 1 ? "s" : "")
									participantsStack.selectedParticipants = selectedParticipants
								}
								Connections {
									target: participantsStack
									function onCurrentItemChanged() {
										if (participantsStack.currentItem == addParticipantLayout) {
											rightPanel.headerTitleText = qsTr("Ajouter des participants")
											rightPanel.headerSubtitleText = qsTr("%1 participant%2 sélectionné%2").arg(addParticipantLayout.selectedParticipants.length).arg(addParticipantLayout.selectedParticipants.length > 1 ? "s" : "")
										}
									}
								}
							}
						}
					}
				}
			}
			Component {
				id: encryptionPanel
				EncryptionSettings {
					call: mainWindow.call
					Control.StackView.onActivated: {
						rightPanel.headerTitleText = qsTr("Chiffrement")
					}
					onEncryptionValidationRequested: zrtpValidation.open()
				}
			}
			Component {
				id: statsPanel
				CallStatistics {
					Control.StackView.onActivated: {
						rightPanel.headerTitleText = qsTr("Statistiques")
					}
					call: mainWindow.call
				}
			}
			Component {
				id: waitingRoom
				WaitingRoom {
					id: waitingRoomIn
					objectName: "waitingRoom"
					Layout.alignment: Qt.AlignCenter		
					onSettingsButtonCheckedChanged: {
						if (settingsButtonChecked) {
							rightPanel.visible = true
							rightPanel.replace(settingsPanel)
						} else {
							rightPanel.visible = false
						}
					}
					Binding {
						target: callStatusIcon
						when: middleItemStackView.currentItem.objectName === "waitingRoom"
						property: "imageSource"
						value: AppIcons.usersThree
						restoreMode: Binding.RestoreBindingOrValue
					}
					Binding {
						target: callStatusText
						when: middleItemStackView.currentItem.objectName === "waitingRoom"
						property: "text"
						value: waitingRoomIn.conferenceInfo ? waitingRoomIn.conferenceInfo.core.subject : ''
						restoreMode: Binding.RestoreBindingOrValue
					}
					Binding {
						target: conferenceDate
						when: middleItemStackView.currentItem.objectName === "waitingRoom"
						property: "text"
						value: waitingRoomIn.conferenceInfo ? waitingRoomIn.conferenceInfo.core.startEndDateString : ''
					}
					Connections {
						target: rightPanel
						function onVisibleChanged(){ if (!visible) waitingRoomIn.settingsButtonChecked = false}
					}
					Connections {
						target:mainWindow
						function onSetUpConferenceRequested(conferenceInfo) {
							waitingRoomIn.conferenceInfo = conferenceInfo
						}
					}
					onJoinConfRequested: (uri) => {
						mainWindow.joinConference(uri, {'microEnabled':microEnabled, 'localVideoEnabled':localVideoEnabled})
					}
					onCancelJoiningRequested: mainWindow.cancelJoinConference()
				}
			}
			Component {
				id: inCallItem
				Loader{
					property string objectName: "inCallItem"
					asynchronous: true
					sourceComponent: Item {
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
			}
	
			
			
			RowLayout {
				id: bottomButtonsLayout
				Layout.alignment: Qt.AlignHCenter
				spacing: 58 * DefaultStyle.dp
				visible: middleItemStackView.currentItem.objectName == "inCallItem"

				function refreshLayout() {
					if (mainWindow.callState === LinphoneEnums.CallState.Connected || mainWindow.callState === LinphoneEnums.CallState.StreamsRunning
					|| mainWindow.callState === LinphoneEnums.CallState.Paused || mainWindow.callState === LinphoneEnums.CallState.PausedByRemote) {
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
					function onCallStateChanged(){ bottomButtonsLayout.refreshLayout()}
					function onCallChanged(){ bottomButtonsLayout.refreshLayout()}
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
						mainWindow.callTerminatedByUser = true
						mainWindow.endCall(mainWindow.call)
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
						enabled: mainWindow.conference || mainWindow.callState != LinphoneEnums.CallState.PausedByRemote
						icon.source: enabled && checked ? AppIcons.play : AppIcons.pause
						checked: mainWindow.call && mainWindow.callState == LinphoneEnums.CallState.Paused || mainWindow.callState == LinphoneEnums.CallState.Pausing || (!mainWindow.conference && mainWindow.callState == LinphoneEnums.CallState.PausedByRemote)
						onClicked: {
							mainWindow.call.core.lSetPaused(!mainWindow.call.core.paused)
						}
					}
					CheckableButton {
						id: transferCallButton
						visible: !mainWindow.conference
						icon.source: AppIcons.transferCall
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						icon.width: 32 * DefaultStyle.dp
						icon.height: 32 * DefaultStyle.dp
						contentImageColor: enabled ? DefaultStyle.grey_0 : DefaultStyle.grey_500
						onCheckedChanged: {
							console.log("checked transfer changed", checked)
							if (checked) {
								rightPanel.visible = true
								rightPanel.replace(callTransferPanel)
							} else {
								rightPanel.visible = false
							}
						}
						Connections {
							target: rightPanel
							function onVisibleChanged(){ if(!rightPanel.visible) transferCallButton.checked = false}
						}
					}
					CheckableButton {
						id: newCallButton
						checkable: true
						icon.source: AppIcons.newCall
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						icon.width: 32 * DefaultStyle.dp
						icon.height: 32 * DefaultStyle.dp
						onCheckedChanged: {
							console.log("checked newcall changed", checked)
							if (checked) {
								rightPanel.visible = true
								rightPanel.replace(newCallPanel)
							} else {
								rightPanel.visible = false
							}
						}
						Connections {
							target: rightPanel
							function onVisibleChanged() { if(!rightPanel.visible) newCallButton.checked = false}
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
						checked: !mainWindow.localVideoEnabled
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
                        visible: !!mainWindow.conference
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
						id: participantListButton
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
						Connections {
							target: rightPanel
							onVisibleChanged: if (!rightPanel.visible) participantListButton.checked = false
						}
					}
					PopupButton {
						id: moreOptionsButton
						Layout.preferredWidth: 55 * DefaultStyle.dp
						Layout.preferredHeight: 55 * DefaultStyle.dp
						contentImageColor: enabled && !checked ? DefaultStyle.grey_0 : DefaultStyle.grey_500
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
							function onOpened() {
								moreOptionsButton.popup.y = - moreOptionsButton.popup.height - moreOptionsButton.popup.padding
							}
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
								visible: mainWindow.conference
								Layout.fillWidth: true
								icon.source: AppIcons.fullscreen
								icon.width: 32 * DefaultStyle.dp
								icon.height: 32 * DefaultStyle.dp
								text: qsTr("Mode Plein écran")
								checkable: true
								onToggled: {
									if(checked) {
										DesktopToolsCpp.screenSaverStatus = false
										mainWindow.showFullScreen()
									}else{
										DesktopToolsCpp.screenSaverStatus = true
										mainWindow.showNormal()
									}
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
								visible: mainWindow.call && !mainWindow.conference && !SettingsCpp.disableCallRecordings
								enabled: mainWindow.call && mainWindow.call.core.recordable
								icon.source: AppIcons.recordFill
								icon.width: 32 * DefaultStyle.dp
								icon.height: 32 * DefaultStyle.dp
								checked: mainWindow.call && mainWindow.call.core.recording
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
								onToggled: {
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
