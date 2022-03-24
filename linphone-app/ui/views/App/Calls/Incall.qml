import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import Utils 1.0
import UtilsCpp 1.0

import App.Styles 1.0

import 'Incall.js' as Logic

// =============================================================================

Rectangle {
	id: incall
	
	// ---------------------------------------------------------------------------
	
	// Used by `IncallFullscreenWindow.qml`.
	readonly property bool cameraActivated: cameraIsReady || previewIsReady
	
	property bool cameraIsReady : false
	property bool previewIsReady : false
	
	property var call
	
	property var _sipAddressObserver: SipAddressesModel.getSipAddressObserver(call.fullPeerAddress, call.fullLocalAddress)
	
	property bool isFullScreen: false	// Use this variable to test if we are in fullscreen. Do not test _fullscreen : we need to clean memory before having the window (see .js file)
	property var _fullscreen: null
	on_FullscreenChanged: if( !_fullscreen) isFullScreen = false
	// ---------------------------------------------------------------------------
	
	color: CallStyle.backgroundColor
	anchors.fill:parent
	
	// ---------------------------------------------------------------------------
	
	Connections {
		target: call
		
		onCameraFirstFrameReceived: Logic.handleCameraFirstFrameReceived(width, height)
		onStatusChanged: Logic.handleStatusChanged (status)
		onVideoRequested: Logic.handleVideoRequested()
	}
	
	ColumnLayout {
		anchors {
			fill: parent
			topMargin: CallStyle.header.topMargin
		}
		
		spacing: 0
		
		// -------------------------------------------------------------------------
		// Call info.
		// -------------------------------------------------------------------------
		
		Item {
			id: info
			
			Layout.fillWidth: true
			Layout.leftMargin: CallStyle.header.leftMargin
			Layout.rightMargin: CallStyle.header.rightMargin
			Layout.preferredHeight: CallStyle.header.contactDescription.height
			
			ActionBar {
				id: leftActions
				
				anchors.left: parent.left
				iconSize: CallStyle.header.iconSize
				
				ActionButton {
					id: callQuality
					
					isCustom: true
					backgroundRadius: 4
					colorSet: CallStyle.buttons.callQuality
					
					percentageDisplayed: 0
					
					onClicked: Logic.openCallStatistics()
					
					// See: http://www.linphone.org/docs/liblinphone/group__call__misc.html#ga62c7d3d08531b0cc634b797e273a0a73
					Timer {
						interval: 500
						repeat: true
						running: true
						triggeredOnStart: true
						
						onTriggered: {
									// Note: `quality` is in the [0, 5] interval and -1.
									var quality = call.quality
									if(quality >= 0)
										callQuality.percentageDisplayed = quality * 100 / 5
									else
										callQuality.percentageDisplayed = 0
							}						
					}
					
					CallStatistics {
						id: callStatistics
						
						call: incall.call
						width: container.width
						
						relativeTo: callQuality
						relativeY: CallStyle.header.stats.relativeY
						
						onClosed: Logic.handleCallStatisticsClosed()
					}
				}
				
				ActionButton {
					isCustom: true
					backgroundRadius: 90
					colorSet: CallStyle.buttons.telKeyad
					
					onClicked: telKeypad.visible = !telKeypad.visible
				}
				
				ActionButton {
					id: callSecure
					isCustom: true
					backgroundRadius: 90
					
					colorSet: incall.call.isSecured ? CallStyle.buttons.secure : CallStyle.buttons.unsecure
					
					onClicked: zrtp.visible = (incall.call.encryption === CallModel.CallEncryptionZrtp)
					
					tooltipText: Logic.makeReadableSecuredString(incall.call.securedString)
				}
			}
			
			ContactDescription {
				id: contactDescription
				
				anchors.centerIn: parent
				horizontalTextAlignment: Text.AlignHCenter
				sipAddress: _sipAddressObserver.peerAddress
				username: UtilsCpp.getDisplayName(sipAddress)
				
				height: parent.height
				width: parent.width - rightActions.width - leftActions.width
				Text {
					id: elapsedTime
					color: CallStyle.header.elapsedTime.color
					font.pointSize: CallStyle.header.elapsedTime.pointSize
					horizontalAlignment: Text.AlignHCenter
					width: parent.width
					
					Timer {
						interval: 1000
						repeat: true
						running: true
						triggeredOnStart: true
						
						onTriggered: {elapsedTime.text = Utils.formatElapsedTime(call.duration);}
					}
				}
			}
			
			// -----------------------------------------------------------------------
			// Video actions.
			// -----------------------------------------------------------------------
			
			ActionBar {
				id: rightActions
				
				anchors.right: parent.right
				iconSize: CallStyle.header.buttonIconSize
				
				ActionButton {
					isCustom: true
					backgroundRadius: 90
					colorSet: CallStyle.buttons.screenshot
				
					visible: incall.call.videoEnabled
					
					onClicked: incall.call.takeSnapshot()
					
					tooltipText:qsTr('takeSnapshotLabel')
				}
				
				ActionButton {
					id: recordingSwitch
					
					isCustom: true
					backgroundRadius: 90
					colorSet: incall.call.recording ? CallStyle.buttons.recordOn : CallStyle.buttons.recordOff
					visible: SettingsModel.callRecorderEnabled
					
					onClicked: {
						var call = incall.call
						return !incall.call.recording
								? call.startRecording()
								: call.stopRecording()
					}
					
					onVisibleChanged: {
						if (!visible) {
							call.stopRecording()
						}
					}
					
					tooltipText: !incall.call.recording
							  ? qsTr('startRecordingLabel')
							  : qsTr('stopRecordingLabel')
				}
				
				ActionButton {
					isCustom: true
					backgroundRadius: 90
					colorSet: CallStyle.buttons.fullscreen
					visible: incall.call.videoEnabled
					
					onClicked: Logic.showFullscreen(contactDescription.mapToGlobal(0,0))
				}
			}
		}
		
		// -------------------------------------------------------------------------
		// Contact visual.
		// -------------------------------------------------------------------------
		
		Item {
			id: container
			
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.margins: CallStyle.container.margins
			
			Component {
				id: avatar
				
				IncallAvatar {
					call: incall.call
					height: Logic.computeAvatarSize(CallStyle.container.avatar.maxSize)
					width: height
				}
			}
			
			Loader {
				id: cameraLoader
				
				anchors.centerIn: parent
				
				active: incall.call.videoEnabled && !isFullScreen
				sourceComponent: camera
				
				Component {
					id: camera
					
					Camera {
						call: incall.call
						height: container.height
						width: container.width
						Component.onDestruction: {
							resetWindowId()
						}
					}
					
				}
			}
			
			Loader {
				anchors.centerIn: parent
				
				active: !call.videoEnabled || isFullScreen
				sourceComponent: avatar
			}
		}
		
		// -------------------------------------------------------------------------
		// Zrtp.
		// -------------------------------------------------------------------------
		
		ZrtpTokenAuthentication {
			id: zrtp
			
			Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
			Layout.margins: CallStyle.container.margins
			
			call: incall.call
			visible: !call.isSecured && call.encryption !== CallModel.CallEncryptionNone
			z: Constants.zPopup
		}
		
		// -------------------------------------------------------------------------
		// Action Buttons.
		// -------------------------------------------------------------------------
		
		Item {
			Layout.fillWidth: true
			Layout.preferredHeight: CallStyle.actionArea.height
			
			GridLayout {
				anchors {
					left: parent.left
					leftMargin: CallStyle.actionArea.leftButtonsGroupMargin
					verticalCenter: parent.verticalCenter
				}
				
				columns: incall.width < CallStyle.actionArea.lowWidth ? 2 : 4
				rowSpacing: ActionBarStyle.spacing
				
				Row {
					spacing: CallStyle.actionArea.vu.spacing
					visible: SettingsModel.muteMicrophoneEnabled
					
					VuMeter {
						Timer {
							interval: 50
							repeat: true
							running: parent.enabled
							
							onTriggered: parent.value = incall.call.microVu
						}
						
						enabled: !incall.call.microMuted
					}
					
					ActionButton {
						id: micro
						isCustom: true
						backgroundRadius: 90
						colorSet: incall.call.microMuted ? CallStyle.buttons.microOff : CallStyle.buttons.microOn
						onClicked: incall.call.microMuted = !incall.call.microMuted
					}
				}
				
				Row {
					spacing: CallStyle.actionArea.vu.spacing
					
					VuMeter {
						Timer {
							interval: 50
							repeat: true
							running: parent.enabled
							
							onTriggered: parent.value = incall.call.speakerVu
						}
						
						enabled: !incall.call.speakerMuted
					}
					
					ActionButton {
						id: speaker
						isCustom: true
						backgroundRadius: 90
						colorSet: incall.call.speakerMuted ? CallStyle.buttons.speakerOff : CallStyle.buttons.speakerOn
						
						onClicked: incall.call.speakerMuted = !incall.call.speakerMuted
					}
				}
				
				ActionButton {
					isCustom: true
					backgroundRadius: 90
					colorSet: incall.call.videoEnabled ? CallStyle.buttons.cameraOn : CallStyle.buttons.cameraOff
					updating: incall.call.videoEnabled && incall.call.updating
					visible: SettingsModel.videoSupported
					
					onClicked: incall.call.videoEnabled = !incall.call.videoEnabled
					
					TooltipArea {
						text: qsTr('pendingRequestLabel')
						visible: parent.updating
					}
				}
				
				ActionButton {
					Layout.preferredHeight: CallStyle.buttons.options.iconSize
					Layout.preferredWidth: CallStyle.buttons.options.iconSize
					
					isCustom: true
					backgroundRadius: 90
					colorSet: CallStyle.buttons.options
					
					onClicked: Logic.openMediaParameters(window, incall)
				}
			}
			
			// -----------------------------------------------------------------------
			// Preview.
			// -----------------------------------------------------------------------
			
			Loader {
				id: cameraPreviewLoader
				
				anchors.centerIn: parent
				height: CallStyle.actionArea.userVideo.height
				width: CallStyle.actionArea.userVideo.width
				active: incall.width >= CallStyle.actionArea.lowWidth && incall.call.videoEnabled && !isFullScreen
				sourceComponent: cameraPreview
				Component {
					id: cameraPreview
					
					Camera {
						anchors.fill: parent
						call: incall.call
						isPreview: true
						Component.onDestruction: {
							resetWindowId()
						}
					}
				}
			}
			
			ActionBar {
				id: bottomActions
				
				anchors {
					right: parent.right
					rightMargin: CallStyle.actionArea.rightButtonsGroupMargin
					verticalCenter: parent.verticalCenter
				}
				iconSize: CallStyle.actionArea.iconSize
				
				ActionButton {
					isCustom: true
					backgroundRadius: 90
					colorSet: call.pausedByUser ? CallStyle.buttons.play : CallStyle.buttons.pause
					updating: incall.call.updating
					visible: SettingsModel.callPauseEnabled
					
					onClicked: incall.call.pausedByUser = !incall.call.pausedByUser
					
					TooltipArea {
						text: qsTr('pendingRequestLabel')
						visible: parent.updating
					}
				}
				
				ActionButton {
					isCustom: true
					backgroundRadius: 90
					colorSet: CallStyle.buttons.hangup
					
					onClicked: incall.call.terminate()
				}
				
				ActionButton {
					isCustom: true
					backgroundRadius: 90
					colorSet: (SettingsModel.standardChatEnabled || SettingsModel.secureChatEnabled) && SettingsModel.showStartChatButton ? CallStyle.buttons.chat : CallStyle.buttons.history
					
					onClicked: {
						if (window.chatIsOpened) {
							window.closeChat()
						} else {
							window.openChat()
						}
					}
				}
			}
		}
	}
	
	// ---------------------------------------------------------------------------
	// TelKeypad.
	// ---------------------------------------------------------------------------
	
	TelKeypad {
		id: telKeypad
		
		call: incall.call
		visible: SettingsModel.showTelKeypadAutomatically
	}
}
