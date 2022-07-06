import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import App.Styles 1.0
import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils


// A sticker display the avatar or its camera view


// =============================================================================
Flipable{
	id: mainItem
	
	property bool flipped : cameraEnabled && camera.isReady
	
	
	property bool showCustomButton: false
	property bool customButtonToggled: false
	property QtObject customButtonColorSet: StickerStyle.custom
	
	property alias currentDevice: camera.currentDevice
	property alias callModel: camera.callModel
	property alias isPaused: camera.isPaused
	property alias isPreview: camera.isPreview
	property alias showCloseButton: camera.showCloseButton
	property alias showActiveSpeakerOverlay: camera.showActiveSpeakerOverlay
	property alias isCameraFromDevice: camera.isCameraFromDevice
	property alias cameraEnabled: camera.cameraEnabled
	
	property alias image: avatar.image
	property alias username: avatar.username
	property alias avatarBackgroundColor: avatar.avatarBackgroundColor
	property alias avatarOutBackgroundColor: avatar.color
	property alias avatarRatio: avatar.avatarRatio
	
	signal videoDefinitionChanged()
	signal customButtonClicked()
	
	transform: Rotation {
						id: rotation
						origin.x: mainItem.width/2
						origin.y: mainItem.height/2
						axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
						angle: 0    // the default angle
				}
				
	states: State {
		name: "back"
		PropertyChanges { target: rotation; angle: 180 }
		when: mainItem.flipped
	}
	property bool quickTransition : flipped
	transitions: Transition {
		SequentialAnimation {
			NumberAnimation { target: rotation; duration: quickTransition || rotation.angle != 0 ? 0 : 300 }
			NumberAnimation { target: rotation; property: "angle"; duration: quickTransition ? 200 : 800 }
		}
	}
						
	front: AvatarSticker{
		id: avatar
		currentDevice: mainItem.currentDevice
		callModel: mainItem.callModel
		isPaused: mainItem.isPaused
		isPreview: mainItem.isPreview
		showCloseButton: mainItem.showCloseButton
		showActiveSpeakerOverlay: mainItem.showActiveSpeakerOverlay
		
		showCustomButton: mainItem.showCustomButton
		customButtonToggled: mainItem.customButtonToggled
		customButtonColorSet: mainItem.customButtonColorSet
	
		height: mainItem.height
		width: mainItem.width
		
		onCustomButtonClicked: mainItem.customButtonClicked()
	}
	back: CameraSticker{
		id: camera
		height: mainItem.height
		width: mainItem.width
		
		showCustomButton: mainItem.showCustomButton
		customButtonToggled: mainItem.customButtonToggled
		customButtonColorSet: mainItem.customButtonColorSet
		
		onVideoDefinitionChanged: mainItem.videoDefinitionChanged()
		onCustomButtonClicked: mainItem.customButtonClicked()
	}
}
