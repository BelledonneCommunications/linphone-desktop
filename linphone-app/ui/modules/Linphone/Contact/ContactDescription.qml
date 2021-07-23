import QtQuick 2.7

import Linphone 1.0
import Linphone.Styles 1.0
import Common 1.0

// =============================================================================

Column {
	property alias username: username.text
	property string sipAddress
	
	property color sipAddressColor: ContactDescriptionStyle.sipAddress.color
	property color usernameColor: ContactDescriptionStyle.username.color
	property int horizontalTextAlignment
	property int contentWidth : username.contentWidth + address.contentWidth
	
	// ---------------------------------------------------------------------------
	
	Text {
		id: username
		
		color: usernameColor
		elide: Text.ElideRight
		font.bold: true
		font.pointSize: ContactDescriptionStyle.username.pointSize
		horizontalAlignment: horizontalTextAlignment
		verticalAlignment: (address.visible?Text.AlignBottom:Text.AlignVCenter)
		width: parent.width
		height: (parent.height-parent.topPadding-parent.bottomPadding)/parent.visibleChildren.length
		//onTextChanged: console.log("username width: "+text+"=>"+contentWidth+"/"+width)
		//onContentWidthChanged: console.log("usr : "+text+"=>"+contentWidth)
	}
	
	Text {
		id:address
		text: SipAddressesModel.cleanSipAddress(sipAddress)
		color: sipAddressColor
		elide: Text.ElideRight
		font.pointSize: ContactDescriptionStyle.sipAddress.pointSize
		horizontalAlignment: horizontalTextAlignment
		verticalAlignment: (username.visible?Text.AlignTop:Text.AlignVCenter)
		width: parent.width
		height: (parent.height-parent.topPadding-parent.bottomPadding)/parent.visibleChildren.length
		visible: text != ''
		//onTextChanged: console.log("address width: "+text+"=>"+contentWidth+"/"+width)
		//onContentWidthChanged: console.log("addr : "+text+"=>"+contentWidth)
	}
	
}
