import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import App.Styles 1.0
import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// Decoration is used to be inherited
// Variables in '_<name>' allow to use alias in inheritance. These variables should not be change inside DecorationSticker

// =============================================================================
Item{
	id: mainItem
	default property alias _content: content.data
	property alias speakingOverlayDisplayed: effect.visible
	property string username: mainItem._currentDevice ? mainItem._currentDevice.displayName : ''
	property bool showUsername: true
	
	property ParticipantDeviceModel _currentDevice
	property CallModel _callModel
	property bool _isPaused
	property bool _isPreview
	property bool _showCloseButton: false
	property bool _showActiveSpeakerOverlay: true
	
	property bool _showCustomButton: false
	property bool _customButtonToggled: false
	property alias _customButtonColorSet : customButton.colorSet
	
	property int radius
	
	signal closeRequested()
	signal backgroundClicked()
	signal customButtonClicked()
	
	MouseArea{
		anchors.fill: parent
		onClicked: mainItem.backgroundClicked()
	}
	 RectangularGlow {
        id: effect
        anchors.fill: content
        glowRadius: 4
        spread: 0.9
        color: DecorationStickerStyle.border.colorModel.color
        cornerRadius: (mainItem.radius? mainItem.radius : 0) + glowRadius
        visible: mainItem._showActiveSpeakerOverlay && mainItem._currentDevice && mainItem._currentDevice.isSpeaking
    }
    Item{
		id: content
		anchors.fill: parent
    }
	
	Rectangle{
		id: hideView
		anchors.fill: parent
		color: DecorationStickerStyle.pauseView.backgroundColor.color
		radius: DecorationStickerStyle.radius
		visible: mainItem._isPaused
		Rectangle{
			anchors.centerIn: parent
			height: DecorationStickerStyle.pauseView.button.iconSize
			width: height
			radius: width/2
			color: DecorationStickerStyle.pauseView.button.backgroundNormalColor.color
			Icon{
				anchors.centerIn: parent
				icon: DecorationStickerStyle.pauseView.button.icon
				overwriteColor: DecorationStickerStyle.pauseView.button.foregroundNormalColor.color
				iconSize: DecorationStickerStyle.pauseView.button.iconSize
			}
		}
	}
	Text{
		id: usernameItem
		visible: mainItem.showUsername && mainItem._currentDevice
		anchors.right: parent.right
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		anchors.margins: 10
		elide: Text.ElideRight
		maximumLineCount: 1
		//: 'paused' : Pause state on sticker, next to username.
		text:  mainItem.username + (mainItem._isPaused ? ' ('+qsTr('paused')+')' : '')
		font.pointSize: DecorationStickerStyle.contactDescription.pointSize
		font.weight: DecorationStickerStyle.contactDescription.weight
		color: DecorationStickerStyle.contactDescription.colorModel.color
	}
	Glow {
		anchors.fill: usernameItem
		visible: usernameItem.visible
		//spread: 1
		radius: 12
		samples: 25
		color: "#80000000"
		source: usernameItem
	}
	Loader{
		id: closeLoader
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.rightMargin: 5
		anchors.topMargin: 5
		active: mainItem._showCloseButton && mainItem._isPreview && mainItem._callModel && mainItem._callModel.videoEnabled
		sourceComponent: Component{
			ActionButton{
				isCustom: true
				colorSet: DecorationStickerStyle.closePreview
				onClicked: mainItem.closeRequested()
			}
		}
	}
	ColumnLayout{
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.topMargin: 10
		anchors.rightMargin: 10
		ActionButton{// Custom action
			id: customButton
			visible: mainItem._showCustomButton
			isCustom: true
			backgroundRadius: width/2
			toggled: mainItem._customButtonToggled
			onClicked: mainItem.customButtonClicked()
		}
		Rectangle{// Mute
			visible: mainItem._currentDevice && mainItem._currentDevice.isMuted
			Layout.preferredHeight: DecorationStickerStyle.isMuted.button.iconSize
			Layout.preferredWidth: DecorationStickerStyle.isMuted.button.iconSize
			radius: width/2
			color: DecorationStickerStyle.isMuted.button.backgroundNormalColor.color
			Icon{
				anchors.centerIn: parent
				icon: DecorationStickerStyle.isMuted.button.icon
				overwriteColor: DecorationStickerStyle.isMuted.button.foregroundNormalColor.color
				iconSize: DecorationStickerStyle.isMuted.button.iconSize
			}
		}
		Loader{
			id: busyLoader
			
			Layout.preferredHeight: 20
			Layout.preferredWidth: 20
			active: mainItem._currentDevice && (mainItem._currentDevice.state == LinphoneEnums.ParticipantDeviceStateJoining || mainItem._currentDevice.state == LinphoneEnums.ParticipantDeviceStateScheduledForJoining || mainItem._currentDevice.state == LinphoneEnums.ParticipantDeviceStateAlerting)
			sourceComponent: Component{
				BusyIndicator{// Joining spinner
					id: joiningSpinner
					running: false
					Timer{// Delay starting spinner (Qt bug)
						id: indicatorDelay
						interval: 100
						onTriggered: joiningSpinner.running = true
					}
					Component.onCompleted: indicatorDelay.start()
				}
			}
		}
	}
}
