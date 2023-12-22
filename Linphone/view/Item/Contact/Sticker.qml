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
	property bool enablePersonalCamera: false
	onEnablePersonalCameraChanged: console.log ("enable camera", enablePersonalCamera)
	property color color: DefaultStyle.grey_600
	property int radius: 15 * DefaultStyle.dp
	property var peerAddress: call ? UtilsCpp.getDisplayName(call.core.peerAddress) : null
	property var identityAddress: account ? UtilsCpp.getDisplayName(account.core.identityAddress) : null

	Rectangle {
		id: background
		color: mainItem.color
		radius: mainItem.radius
		anchors.fill: parent
		ColumnLayout {
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
				text: mainItem.peerAddress ? mainItem.peerAddress.value : ""
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
			active: mainItem.visible && call ? call.core.remoteVideoEnabled : mainItem.enablePersonalCamera
			onActiveChanged: console.log("camera active", active)
			sourceComponent: cameraComponent
		}
		Component{
			id: cameraComponent
			Item {
				height: cameraLoader.height
				width: cameraLoader.width
				property bool isReady: cameraItem.visible
				CameraGui{
					id: cameraItem
					anchors.fill: parent
					visible: isReady
					call: mainItem.call
					
					onRequestNewRenderer: {
						console.log("Request new renderer")
						resetTimer.restart()
					}
				}
			}
		}
		Text {
			id: bottomAddress
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			anchors.leftMargin: 10 * DefaultStyle.dp
			anchors.bottomMargin: 10 * DefaultStyle.dp
			width: txtMeter.width
			text: mainItem.call && mainItem.peerAddress
				? mainItem.peerAddress.value
				: mainItem.account && mainItem.identityAddress
					? mainItem.identityAddress.value
					: ""
			color: DefaultStyle.grey_0
			font {
				pixelSize: 14 * DefaultStyle.dp
				weight: 500 * DefaultStyle.dp
			}
		}
		TextMetrics {
			id: txtMeter
			text: bottomAddress.text
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
