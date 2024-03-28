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
	property CallGui call: null
	property AccountGui account: null
	property ParticipantDeviceGui participantDevice: null
	property bool previewEnabled: false
	property bool displayBorder : participantDevice && participantDevice.core.isSpeaking || false
	property color color: DefaultStyle.grey_600
	property int radius: 15 * DefaultStyle.dp
	property var peerAddressObj: participantDevice && participantDevice.core
									? UtilsCpp.getDisplayName(participantDevice.core.address)
									: call && call.core
										? UtilsCpp.getDisplayName(call.core.peerAddress)
										: null
	property string peerAddress:peerAddressObj ? peerAddressObj.value : ""
	property var identityAddress: account ? UtilsCpp.getDisplayName(account.core.identityAddress) : null
	property bool cameraEnabled: previewEnabled
	property string qmlName

	Rectangle {
		id: background
		color: noCameraLayout.visible ? mainItem.color : 'transparent'
		radius: mainItem.radius
		anchors.fill: parent
		border.color: DefaultStyle.main2_200
		border.width: mainItem.displayBorder ? 3 * DefaultStyle.dp : 0
		ColumnLayout {
			id: noCameraLayout
			anchors.centerIn: parent
			visible: !cameraLoader.active || cameraLoader.status != Loader.Ready || !cameraLoader.item.isReady
			Avatar{
				Layout.alignment: Qt.AlignHCenter
				height: 100
				width: height
				account: mainItem.account
				call: mainItem.call
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				Layout.topMargin: 15 * DefaultStyle.dp
				visible: mainItem.call && mainItem.call != undefined
				text: mainItem.peerAddress
				color: DefaultStyle.grey_0
				font {
					pixelSize: 22 * DefaultStyle.dp
					weight: 300 * DefaultStyle.dp
					capitalization: Font.Capitalize
				}
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				visible: mainItem.call && mainItem.call != undefined
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
			Timer{
				id: resetTimer
				interval: 1
				onTriggered: {cameraLoader.active=false; cameraLoader.active=true;}
			}
			active: mainItem.visible && mainItem.cameraEnabled
			onActiveChanged: console.log("("+mainItem.qmlName+") Camera active " + active)
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
					call: mainItem.call
					participantDevice: mainItem.participantDevice
					isPreview: mainItem.previewEnabled
					onRequestNewRenderer: {
						console.log("Request new renderer")
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
		shadowOpacity: 0.4
	}
}
