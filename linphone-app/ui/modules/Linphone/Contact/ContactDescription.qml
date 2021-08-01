import QtQuick 2.7

import Linphone 1.0
import Linphone.Styles 1.0
import Common 1.0

// =============================================================================

Column {
	property alias username: username.text
	property string sipAddress
	property alias statusText : status.text
	
	property var contactDescriptionStyle : ContactDescriptionStyle
	
	property color sipAddressColor: contactDescriptionStyle.sipAddress.color
	property color usernameColor: contactDescriptionStyle.username.color
	property int horizontalTextAlignment
	property int contentWidth : Math.max(username.implicitWidth, address.implicitWidth)
									+10
									+statusWidth
	property int contentHeight : Math.max(username.implicitHeight, address.implicitHeight)+10
	
	readonly property int statusWidth : (status.visible ? status.width + 5 : 0)
	
	
	
	// ---------------------------------------------------------------------------
	
	Text {
		id: username
		anchors.horizontalCenter: (horizontalTextAlignment == Text.AlignHCenter ? parent.horizontalCenter : undefined)
		color: usernameColor
		elide: Text.ElideRight
		font.weight: contactDescriptionStyle.username.weight
		font.pointSize: contactDescriptionStyle.username.pointSize
		horizontalAlignment: horizontalTextAlignment
		verticalAlignment: (address.visible?Text.AlignBottom:Text.AlignVCenter)
		width: Math.min(parent.width-statusWidth, implicitWidth)
		height: (parent.height-parent.topPadding-parent.bottomPadding)/parent.visibleChildren.length
		Text{
			id:status
			anchors.top:parent.top
			anchors.bottom : parent.bottom
			anchors.left:parent.right
			anchors.leftMargin:5
			verticalAlignment: Text.AlignVCenter
			visible: text != ''
			text : ''
			color: contactDescriptionStyle.username.status.color
			font.pointSize: contactDescriptionStyle.username.status.pointSize
			font.italic : true
		}
	}
	
	Text {
		id:address
		anchors.horizontalCenter: (horizontalTextAlignment == Text.AlignHCenter ? parent.horizontalCenter : undefined)
		text: SipAddressesModel.cleanSipAddress(sipAddress)
		color: sipAddressColor
		elide: Text.ElideRight
		font.weight: contactDescriptionStyle.sipAddress.weight
		font.pointSize: contactDescriptionStyle.sipAddress.pointSize
		horizontalAlignment: horizontalTextAlignment
		verticalAlignment: (username.visible?Text.AlignTop:Text.AlignVCenter)
		width: Math.min(parent.width-statusWidth, implicitWidth)
		height: (parent.height-parent.topPadding-parent.bottomPadding)/parent.visibleChildren.length
		visible: text != ''
	}
	
}
