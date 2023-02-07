import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import Utils 1.0
import UtilsCpp 1.0

// =============================================================================

Item {
	id: avatar
	
	// ---------------------------------------------------------------------------
	
	property alias presenceLevel: presenceLevelIcon.level
	property bool isDarkMode: false
	property color backgroundColor: isDarkMode ? AvatarStyle.backgroundDarkModeColor : AvatarStyle.backgroundColor
	property color foregroundColor: 'transparent'
	property string username
	property var image
	property bool isOneToOne: true
	
	property var _initialsRegex: /^\s*([^\s\.]+)(?:[\s\.]+([^\s\.]+))?/
	
	property bool isPhoneNumber: UtilsCpp.isPhoneNumber(username)
	
	// ---------------------------------------------------------------------------
	
	function isLoaded () {
		return roundedImage.status === Image.Ready
	}
	
	function _computeInitials () {
		return UtilsCpp.getInitials(username);
	}
	
	// ---------------------------------------------------------------------------
	
	RoundedImage {
		id: roundedImage
		
		anchors.fill: parent
		backgroundColor: avatar.backgroundColor
		foregroundColor: avatar.foregroundColor
		source: avatar.image || ''
		Icon{
			anchors.fill: parent
			icon: AvatarStyle.personImage
			visible: parent.source == '' && avatar.isPhoneNumber
			overwriteColor: AvatarStyle.initials.color
		}
	}
	
	Text {
		id: initialsText
		anchors.centerIn: parent
		color: isDarkMode ? AvatarStyle.initials.darkModeColor : AvatarStyle.initials.color
		font.family: SettingsModel.textMessageFont.family
		font.pointSize: {
			var width
			
			if (parent.width > 0) {
				width = parent.width / AvatarStyle.initials.ratio
			}
			
			return AvatarStyle.initials.pointSize * (width || 1)
		}
		
		text: _computeInitials()
		visible: roundedImage.status !== Image.Ready && !avatar.isPhoneNumber && avatar.isOneToOne
	}
	
	Icon {
		anchors.fill: parent
		icon: ContactStyle.groupChat.icon
		overwriteColor: isDarkMode ? ContactStyle.groupChat.avatarDarkModeColor : ContactStyle.groupChat.avatarColor
		iconSize: avatar.width
		//visible: entry!=undefined && entry.isOneToOne!=undefined && !entry.isOneToOne
		visible: !avatar.isOneToOne
	}
	
	PresenceLevel {
		id: presenceLevelIcon
		visible: level >= 0
		
		anchors {
			bottom: parent.bottom
			right: parent.right
		}
		
		height: parent.height / 4
		width: parent.width / 4
	}
}
