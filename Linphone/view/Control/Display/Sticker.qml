import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp

// Display a sticker from a call or from an account.
// The Avatar is shown while the camera become available.
// The loader restart in case of resetting the renderer. This allow to display the avatar while loading.

// TODO: sizes, colors, decorations
Item {
	id: mainItem
	height: 300
	width: 200
	property bool previewEnabled
	property CallGui call: null
	property ConferenceGui conference: call && call.core.conference || null
	property var callState: call && call.core.state || undefined
	property AccountGui account: null
	property ParticipantDeviceGui participantDevice: null
	property bool displayBorder : participantDevice && participantDevice.core.isSpeaking || false
	property alias displayPresence: avatar.displayPresence
	property color color: DefaultStyle.grey_600
	property int radius: 15 * DefaultStyle.dp
	property bool remoteIsPaused: participantDevice
		? participantDevice.core.isPaused
		: previewEnabled
			? callState === LinphoneEnums.CallState.Paused
			: callState === LinphoneEnums.CallState.PausedByRemote
	property var peerAddressObj: previewEnabled && (call || account)
									? UtilsCpp.getDisplayName(account ? account.core.identityAddress : call.core.localAddress)
									: participantDevice && participantDevice.core
										? UtilsCpp.getDisplayName(participantDevice.core.address)
										: !previewEnabled && call && call.core
											? UtilsCpp.getDisplayName(call.core.peerAddress)
											: null
											
	property string peerAddress:peerAddressObj ? peerAddressObj.value : ""
	property var identityAddress: account ? UtilsCpp.getDisplayName(account.core.identityAddress) : null
	property bool videoEnabled: (previewEnabled && call && call.core.localVideoEnabled)
									|| (participantDevice && participantDevice.core.videoEnabled)
	property string qmlName
	property bool displayAll : !!mainItem.call
	property bool mutedStatus: participantDevice ? participantDevice.core.isMuted : false
	clip: false
	onCallChanged: {
		waitingTime.seconds = 0
		waitingTimer.restart()
	}
	Rectangle {
		id: background
		color: noCameraLayout.visible ? mainItem.color : 'transparent'
		radius: mainItem.radius
		anchors.fill: parent
		border.color: DefaultStyle.main2_200
		border.width: mainItem.displayBorder ? 3 * DefaultStyle.dp : 0
		property int minSize: Math.min(height, width)
		Item {
			id: noCameraLayout
			anchors.fill: parent
			visible: !cameraLoader.active || cameraLoader.status != Loader.Ready || !cameraLoader.item.isReady
			ColumnLayout {
				anchors.top: parent.top
				anchors.topMargin: 81 * DefaultStyle.dp
				anchors.horizontalCenter: parent.horizontalCenter
				// Layout.alignment: Qt.AlignHCenter |Qt.AlignTop
				spacing: 0
				visible: !mainItem.account && (mainItem.callState === LinphoneEnums.CallState.OutgoingInit
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingProgress
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingRinging
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingEarlyMedia
						|| mainItem.callState === LinphoneEnums.CallState.IncomingReceived)
				BusyIndicator {
					indicatorColor: DefaultStyle.main2_100
					Layout.alignment: Qt.AlignHCenter
					indicatorHeight: 27 * DefaultStyle.dp
					indicatorWidth: 27 * DefaultStyle.dp
				}
				Timer {
					id: waitingTimer
					interval: 1000
					repeat: true
					onTriggered: waitingTime.seconds += 1
				}
				Text {
					id: waitingTime
					property var isMeObj: UtilsCpp.isMe(mainItem.peerAddress) 
					visible: isMeObj ? !isMeObj.value : false
					property int seconds
					text: UtilsCpp.formatElapsedTime(seconds)
					color: DefaultStyle.grey_0
					Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					Layout.topMargin: 25 * DefaultStyle.dp
					font {
						pixelSize: 30 * DefaultStyle.dp
						weight: 300 * DefaultStyle.dp
					}
					Component.onCompleted: {
						waitingTimer.restart()
					}
				}
			}
			Item{
				id: centerItem
				visible: !mainItem.remoteIsPaused
				anchors.centerIn: parent
				height: mainItem.conference 
					? background.minSize * 142 / 372
					: 120 * DefaultStyle.dp
				width: height
				Avatar{
					id: avatar
					anchors.fill: parent
					visible: !joiningView.visible
					account: mainItem.account
					call: !mainItem.previewEnabled ? mainItem.call : null
					_address: mainItem.peerAddress
				}
				ColumnLayout{
					id: joiningView
					anchors.centerIn: parent
					spacing: 0
					visible: mainItem.participantDevice && (mainItem.participantDevice.core.state == LinphoneEnums.ParticipantDeviceState.Joining || mainItem.participantDevice.core.state == LinphoneEnums.ParticipantDeviceState.Alerting) || false
					BusyIndicator {
						Layout.preferredHeight: 42 * DefaultStyle.dp
						indicatorColor: DefaultStyle.main2_100
						Layout.alignment: Qt.AlignHCenter
						indicatorHeight: 42 * DefaultStyle.dp
						indicatorWidth: 42 * DefaultStyle.dp
					}
					Text {
						Layout.preferredHeight: 27 * DefaultStyle.dp
						Layout.topMargin: 15 * DefaultStyle.dp // (84-27)-42
						text: qsTr('rejoint...')
						color: DefaultStyle.grey_0
						Layout.alignment: Qt.AlignHCenter
						horizontalAlignment: Text.AlignHCenter
						font {
							pixelSize: 20 * DefaultStyle.dp
							weight: 500 * DefaultStyle.dp
						}
					}
				}
			}
			ColumnLayout {
				anchors.centerIn: parent
				spacing: 12 * DefaultStyle.dp
				visible: mainItem.remoteIsPaused
				EffectImage {
					imageSource: AppIcons.pause
					colorizationColor: DefaultStyle.grey_0
					Layout.preferredHeight: background.width / 8
					Layout.preferredWidth: height
					Layout.alignment: Qt.AlignHCenter
				}
				Text {
					color: DefaultStyle.grey_0
					Layout.alignment: Qt.AlignHCenter
					text: qsTr("En pause")
					font {
						pixelSize: 20 * DefaultStyle.dp
						weight: 500 * DefaultStyle.dp
					}
				}
			}
			ColumnLayout {
				spacing: 0
				visible: mainItem.displayAll && !mainItem.remoteIsPaused && !mainItem.conference
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: centerItem.bottom
				anchors.topMargin: 21 * DefaultStyle.dp
				Text {
					Layout.fillWidth: true
					horizontalAlignment: Text.AlignHCenter
					text: mainItem.peerAddress
					color: DefaultStyle.grey_0
					font {
						pixelSize: 22 * DefaultStyle.dp
						weight: 300 * DefaultStyle.dp
						capitalization: Font.Capitalize
					}
				}
				Text {
					Layout.fillWidth: true
					horizontalAlignment: Text.AlignHCenter
					property string _text: mainItem.call && mainItem.call.core.peerAddress
					text: SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(_text) : _text
					color: DefaultStyle.grey_0
					font {
						pixelSize: 14 * DefaultStyle.dp
						weight: 300 * DefaultStyle.dp
					}
				}
			}
		}
		Loader{
			id: cameraLoader
			anchors.fill: parent
			property bool reset: false
			Timer{
				id: resetTimer
				interval: 1
				triggeredOnStart: true
				onTriggered: {cameraLoader.reset = !cameraLoader.reset}
			}
			active: mainItem.visible && !mainItem.remoteIsPaused 
				&& mainItem.callState != LinphoneEnums.CallState.End 
				&& mainItem.callState != LinphoneEnums.CallState.Released
				&& mainItem.callState != LinphoneEnums.CallState.Paused 
				&& mainItem.callState != LinphoneEnums.CallState.PausedByRemote
				&& mainItem.videoEnabled && !cameraLoader.reset
			onActiveChanged: console.log("("+mainItem.qmlName+") Camera active " + active +", visible="+mainItem.visible +", videoEnabled="+mainItem.videoEnabled +", reset="+cameraLoader.reset)
			sourceComponent: cameraComponent
		}
		Component{
			id: cameraComponent
			Item {
				height: cameraLoader.height
				width: cameraLoader.width
				property alias isReady: cameraItem.isReady
				CameraGui{
					id: cameraItem
					anchors.fill: parent
					visible: false
					qmlName: mainItem.qmlName
					isPreview: mainItem.previewEnabled
					call: mainItem.call
					participantDevice: mainItem.participantDevice
					
					onRequestNewRenderer: {
						console.log("Request new renderer for " +mainItem.qmlName)
						resetTimer.restart()
					}
					layer.enabled: true
				}

				ShaderEffect {
					id: roundEffect
					property variant src: cameraItem
					property real edge: 0.9
					property real edgeSoftness: 0.9
					property real radius: mainItem.radius
					property real shadowSoftness: 0.5
					property real shadowOffset: 0.01
					anchors.fill: parent
					visible: cameraItem.isReady
					fragmentShader: 'qrc:/data/shaders/roundEffect.frag.qsb'
				}
			}
		}
		Text {
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			anchors.leftMargin: 10 * DefaultStyle.dp
			anchors.bottomMargin: 10 * DefaultStyle.dp
			width: implicitWidth
			property string _text: mainItem.peerAddress != ''
				? mainItem.peerAddress
				: mainItem.account && mainItem.identityAddress
					? mainItem.identityAddress.value
					: ""
			text: SettingsCpp.onlyDisplaySipUriUsername ? UtilsCpp.getUsername(_text) : _text
			color: DefaultStyle.grey_0
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 500 * DefaultStyle.dp
			}
		}
	}
	MultiEffect {
		id: shadow
		source: background
		anchors.fill: background
		shadowEnabled: true
		shadowColor: DefaultStyle.grey_1000
		shadowBlur: 1
		shadowScale: 1.05
		shadowOpacity: 0.5
	}
	RowLayout{
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.rightMargin: 8 * DefaultStyle.dp
		anchors.topMargin: 8 * DefaultStyle.dp
		
		height: 18 * DefaultStyle.dp
		spacing: 0
		CheckableButton {
			id: muteIcon
			icon.source: AppIcons.microphoneSlash
			Layout.preferredWidth: Math.min(mainItem.width / 16, 20 * DefaultStyle.dp)
			Layout.preferredHeight: Math.min(mainItem.width / 16, 20 * DefaultStyle.dp)
			visible: mainItem.mutedStatus
			icon.width: Math.min(mainItem.width / 16, 20 * DefaultStyle.dp)
			icon.height: Math.min(mainItem.width / 16, 20 * DefaultStyle.dp)
			enabled: false
			contentImageColor: DefaultStyle.main2_500main
			backgroundColor: DefaultStyle.grey_0
		}
	}
}
