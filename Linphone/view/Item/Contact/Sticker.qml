import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp 1.0

// Display a sticker from a call or from an account.
// The Avatar is shown while the camera become available.
// The loader restart in case of resetting the renderer. This allow to display the avatar while loading.

// TODO: sizes, colors, decorations
Rectangle{
	id: mainItem
	height: 300
	width: 200
	property CallGui call: null
	property AccountGui account: null
	color: 'gray'
	Avatar{
		anchors.centerIn: parent
		height: 100
		width: height
		account: mainItem.account
		call: mainItem.call
		visible: !cameraLoader.active || cameraLoader.status != Loader.Ready || !cameraLoader.item.isReady
	}
	Loader{
		id: cameraLoader
		anchors.fill: parent
		Timer{
			id: resetTimer
			interval: 1
			onTriggered: {cameraLoader.active=false; cameraLoader.active=true;}
		}
		active: mainItem.visible && (!call || call.core.remoteVideoEnabled)
		sourceComponent: cameraComponent
	}
	Component{
		id: cameraComponent
		Item{
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
}
