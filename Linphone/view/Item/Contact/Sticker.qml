import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp 1.0

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
	property AccountGui account: null
	property ParticipantDeviceGui participantDevice: null
	property bool displayBorder : participantDevice && participantDevice.core.isSpeaking || false
	property alias displayPresence: avatar.displayPresence
	property color color: DefaultStyle.grey_600
	property int radius: 15 * DefaultStyle.dp
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
	property bool bigBottomAddress: displayAll
	property bool mutedStatus: participantDevice ? participantDevice.core.isMuted : false

	Rectangle {
		id: background
		color: noCameraLayout.visible ? mainItem.color : 'transparent'
		radius: mainItem.radius
		anchors.fill: parent
		border.color: DefaultStyle.main2_200
		border.width: mainItem.displayBorder ? 3 * DefaultStyle.dp : 0
		property int minSize: Math.min(height, width)
		ColumnLayout {
			id: noCameraLayout
			anchors.fill: parent
			spacing: 0
			visible: !cameraLoader.active || cameraLoader.status != Loader.Ready || !cameraLoader.item.isReady
			Avatar{
				id: avatar
				Layout.alignment: Qt.AlignHCenter
				// minSize = 372 => avatar = 142
				Layout.preferredHeight: background.minSize * 142 / 372
				Layout.preferredWidth: height
				account: mainItem.account
				call: !mainItem.previewEnabled ? mainItem.call : null
				address: mainItem.peerAddress
			}
			Text {
				Layout.fillWidth: true
				Layout.topMargin: 15 * DefaultStyle.dp
				horizontalAlignment: Text.AlignHCenter
				visible: mainItem.displayAll
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
				visible: mainItem.displayAll
				text: mainItem.call && mainItem.call.core.peerAddress
				color: DefaultStyle.grey_0
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 300 * DefaultStyle.dp
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
			active: mainItem.visible && mainItem.videoEnabled && !cameraLoader.reset
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
			id: bottomAddress
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			anchors.leftMargin: 10 * DefaultStyle.dp
			anchors.bottomMargin: 10 * DefaultStyle.dp
			width: implicitWidth
			text: mainItem.peerAddress != ''
				? mainItem.peerAddress
				: mainItem.account && mainItem.identityAddress
					? mainItem.identityAddress.value
					: ""
			color: DefaultStyle.grey_0
			font {
				pixelSize: (mainItem.bigBottomAddress ? 14 : 10) * DefaultStyle.dp
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
		shadowOpacity: 0.4
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
			Layout.preferredWidth: 18 * DefaultStyle.dp
			Layout.preferredHeight: 18 * DefaultStyle.dp
			visible: mainItem.mutedStatus
			icon.width: 13 * DefaultStyle.dp
			icon.height: 13 * DefaultStyle.dp
			enabled: false
			contentImageColor: DefaultStyle.main2_500main
			backgroundColor: DefaultStyle.grey_0
		}
	}
}
