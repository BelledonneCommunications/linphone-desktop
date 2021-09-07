import QtQuick 2.7

import Linphone 1.0
import Linphone.Styles 1.0
import Common 1.0

// =============================================================================

Column {
	id:mainItem
	property alias username: username.fullText
	property string sipAddress
	property string participants
	
	property alias statusText : status.text
	
	property var contactDescriptionStyle : ContactDescriptionStyle
	
	property color sipAddressColor: contactDescriptionStyle.sipAddress.color
	property color usernameColor: contactDescriptionStyle.username.color
	property int horizontalTextAlignment
	property int contentWidth : Math.max(usernameImplicitWidthWorkaround.implicitWidth, addressImplicitWidthWorkaround.implicitWidth)
									+10
									+statusWidth
	property int contentHeight : Math.max(username.implicitHeight, address.implicitHeight)+10
	
	readonly property int statusWidth : (status.visible ? status.width + 5 : 0)
	
	property bool usernameClickable: false
	
	signal usernameClicked()

	
	
	
	// ---------------------------------------------------------------------------
	/*
	 TextEdit {
          id: appVersion
          color: AboutStyle.versionsBlock.appVersion.color
          selectByMouse: true
          font.pointSize: AboutStyle.versionsBlock.appVersion.pointSize
          text: 'Desktop ' + Qt.application.version + ' - Qt' + App.qtVersion +'\nCore ' + CoreManager.version

          height: parent.height
          width: parent.width   

          verticalAlignment: Text.AlignVCenter

          onActiveFocusChanged: deselect();
        }
        
	*/
	//Text {
	TextEdit {
		id: username
		property string fullText
		anchors.horizontalCenter: (horizontalTextAlignment == Text.AlignHCenter ? parent.horizontalCenter : undefined)
		color: usernameColor
		font.weight: contactDescriptionStyle.username.weight
		font.pointSize: contactDescriptionStyle.username.pointSize
		horizontalAlignment: horizontalTextAlignment
		verticalAlignment: (address.visible?Text.AlignBottom:Text.AlignVCenter)
		width: Math.min(parent.width-statusWidth, usernameImplicitWidthWorkaround.implicitWidth)
		height: (parent.height-parent.topPadding-parent.bottomPadding)/parent.visibleChildren.length
		
		text: metrics.elidedText
		onActiveFocusChanged: deselect();
		readOnly: true
		selectByMouse: true
		
		Text{// Workaround to get implicitWidth from text without eliding
				id: usernameImplicitWidthWorkaround
				text: username.fullText
				font.weight: username.font.weight
				font.pointSize: username.font.pointSize
				visible: false
			}
		
		TextMetrics {
			id: metrics
			font: username.font
			text: username.fullText
			elideWidth: username.width
			elide: Qt.ElideRight
		}
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
		MouseArea{
			anchors.fill:parent
			visible: usernameClickable
			onClicked: usernameClicked()
		}
	}
	
	TextEdit {
		id:address
		property string fullText: sipAddress?SipAddressesModel.cleanSipAddress(sipAddress):participants
		anchors.horizontalCenter: (horizontalTextAlignment == Text.AlignHCenter ? parent.horizontalCenter : undefined)
		color: sipAddressColor
		font.weight: contactDescriptionStyle.sipAddress.weight
		font.pointSize: contactDescriptionStyle.sipAddress.pointSize
		horizontalAlignment: horizontalTextAlignment
		verticalAlignment: (username.visible?Text.AlignTop:Text.AlignVCenter)
		width: Math.min(parent.width-statusWidth, addressImplicitWidthWorkaround.implicitWidth)
		height: (parent.height-parent.topPadding-parent.bottomPadding)/parent.visibleChildren.length
		visible: text != ''
		
		text: addressMetrics.elidedText
		onActiveFocusChanged: deselect();
		readOnly: true
		selectByMouse: true
		Text{// Workaround to get implicitWidth from text without eliding
			id: addressImplicitWidthWorkaround
			text: address.fullText
			font.weight: address.font.weight
			font.pointSize: address.font.pointSize
			visible: false
		}
		
		TextMetrics {
			id: addressMetrics
			font: address.font
			text: address.fullText
			elideWidth: address.width
			elide: Qt.ElideRight
		}
	}
	
}
