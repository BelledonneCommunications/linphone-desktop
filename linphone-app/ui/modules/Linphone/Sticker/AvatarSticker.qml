import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import App.Styles 1.0
import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

DecorationSticker {
	id:mainItem
	
	property ParticipantDeviceModel currentDevice
	property CallModel callModel
	property alias isPaused: avatar.isPaused
	
	property bool showCloseButton: false
	property bool showActiveSpeakerOverlay: true
	property real avatarRatio : 2/3
	property color color : AvatarStickerStyle.stickerBackgroundColor.color
	
	property alias image: avatar.image
	property alias avatarBackgroundColor: avatar.backgroundColor
	property alias avatarUsername: avatar.username
	property alias conferenceInfoModel: avatar.conferenceInfoModel
	property alias isPreview: avatar.isPreview
	property bool showAvatarBorder: false
	
	property alias showCustomButton: mainItem._showCustomButton
	property alias customButtonToggled: mainItem._customButtonToggled
	property alias customButtonColorSet: mainItem._customButtonColorSet
	
	_currentDevice: currentDevice
	_callModel: callModel
	_isPaused: isPaused
	_isPreview: isPreview
	_showCloseButton: showCloseButton
	_showActiveSpeakerOverlay: showActiveSpeakerOverlay
	username: avatarUsername
	
	clip:false
	radius: AvatarStickerStyle.radius
	
	_content: Rectangle{
		anchors.fill: parent
		color: mainItem.color
		radius: mainItem.radius
		border.color: '#40000000'
		border.width: mainItem.showAvatarBorder && !mainItem.speakingOverlayDisplayed? 1 : 0
		
		IncallAvatar {
			id: avatar
			anchors.centerIn: parent
			participantDeviceModel: mainItem.currentDevice
			call: participantDeviceModel ? undefined : mainItem.callModel
			height: Utils.computeAvatarSize(mainItem, mainItem.width, avatarRatio)
			width: height
			backgroundColor: AvatarStickerStyle.inBackgroundColor.color
		}
	}
}
