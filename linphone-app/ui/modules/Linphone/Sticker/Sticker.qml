import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import App.Styles 1.0
import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils
import UtilsCpp 1.0


// A sticker display the avatar or its camera view


// =============================================================================
Item{
	id: mainItem
	
	property bool flipped : !deactivateCamera && camera.isReady
	
	
	property bool showCustomButton: false
	property bool showUsername: true
	property bool customButtonToggled: false
	property QtObject customButtonColorSet: StickerStyle.custom
	
	property alias currentDevice: camera.currentDevice
	property alias callModel: camera.callModel
	property alias isPaused: camera.isPaused
	property alias isPreview: camera.isPreview
	property alias showCloseButton: camera.showCloseButton
	property alias showActiveSpeakerOverlay: camera.showActiveSpeakerOverlay
	property alias isCameraFromDevice: camera.isCameraFromDevice
	property alias deactivateCamera: camera.deactivateCamera
	readonly property alias isVideoEnabled: camera.isVideoEnabled
	property alias cameraQmlName: camera.cameraQmlName
	
	property alias image: avatar.image
	property alias avatarBackgroundColor: avatar.avatarBackgroundColor
	property alias avatarStickerBackgroundColor: avatar.color
	property alias avatarRatio: avatar.avatarRatio
	property alias showAvatarBorder: avatar.showAvatarBorder
	property alias avatarUsername: avatar.avatarUsername
	property alias conferenceInfoModel: avatar.conferenceInfoModel
	
	signal videoDefinitionChanged()
	signal customButtonClicked()
	
	property alias username: avatar.username
	
	function resetCamera(){
		camera.resetCamera()
	}
	
	clip:false
	state: mainItem.flipped ? 'back' : 'front'
	states: [State {
			name: "front"
		}, State {
			name: "back"
		}
	]
	property bool quickTransition : false
	property alias cameraOpacity: camera.opacity
	transitions: [Transition {
			from: 'front'
			to: 'back'
			SequentialAnimation {
				NumberAnimation { target: mainItem; duration: quickTransition ? 0 : 400 }
				NumberAnimation { target: camera; property: 'opacity'; to:1.0; duration: 100;}
			}
		},
		Transition {
			from: 'back'
			to: 'front'
			SequentialAnimation {
				NumberAnimation { target: mainItem; duration: 0 }
				NumberAnimation { target: camera; property: 'opacity'; to:0.0; duration: 100;}
			}
		}
	]
	
	
	AvatarSticker{
		id: avatar
		currentDevice: mainItem.currentDevice
		callModel: mainItem.callModel
		isPaused: mainItem.isPaused
		isPreview: mainItem.isPreview
		showCloseButton: mainItem.showCloseButton
		showActiveSpeakerOverlay: mainItem.showActiveSpeakerOverlay
		showUsername: mainItem.showUsername
		
		showCustomButton: mainItem.showCustomButton
		customButtonToggled: mainItem.customButtonToggled
		customButtonColorSet: mainItem.customButtonColorSet
	
		height: mainItem.height
		width: mainItem.width
		
		onCustomButtonClicked: mainItem.customButtonClicked()
	}
	
	CameraSticker{
		id: camera
		height: mainItem.height
		width: mainItem.width
		opacity: 0.0
		username: mainItem.username
		showUsername: mainItem.showUsername
		
		showCustomButton: mainItem.showCustomButton
		customButtonToggled: mainItem.customButtonToggled
		customButtonColorSet: mainItem.customButtonColorSet
		
		onVideoDefinitionChanged: mainItem.videoDefinitionChanged()
		onCustomButtonClicked: mainItem.customButtonClicked()
	}
}
