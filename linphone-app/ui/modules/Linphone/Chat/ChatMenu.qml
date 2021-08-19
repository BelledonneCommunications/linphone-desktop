import QtQuick 2.7
import QtQuick.Layouts 1.3

import Clipboard 1.0
import Common 1.0
import Linphone 1.0

import Common.Styles 1.0
import Linphone.Styles 1.0
import TextToSpeech 1.0
import Utils 1.0
import Units 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import 'Message.js' as Logic

// =============================================================================

Item {
	id: container
	property string lastTextSelected
	property string content
	property int deliveryCount : 0
	
	signal deliveryStatusClicked()
	signal removeEntryRequested()

	function open(){
		messageMenu.open()
	}
	
	
	Menu {
		id: messageMenu
		menuStyle : MenuStyle.aux
		MenuItem {
			//: 'Copy all' : Text menu to copy all message text into clipboard
			text: (container.lastTextSelected == '' ? qsTr('menuCopyAll')
													  //: 'Copy' : Text menu to copy selected text in message into clipboard
													:  qsTr('menuCopy'))
			iconMenu: 'menu_copy_text'
			iconSizeMenu: 17
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			onTriggered: Clipboard.text = (container.lastTextSelected == '' ? container.content : container.lastTextSelected)
			visible: content != ''
		}
		
		MenuItem {
			enabled: TextToSpeech.available
			text: qsTr('menuPlayMe')
			iconMenu: 'speaker'
			iconSizeMenu: 17
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			onTriggered: TextToSpeech.say(container.content)
			visible: content != ''
		}
		MenuItem {
			//: 'Delivery status' : Item menu that lead to IMDN of a message
			text: qsTr('menuDeliveryStatus')
			iconMenu: 'menu_imdn_info'
			iconSizeMenu: 17
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			visible: container.deliveryCount > 0
			onTriggered: container.deliveryStatusClicked()
		}
		MenuItem {
			//: 'Delete' : Item menu to delete a message
			text: qsTr('menuDelete')
			iconMenu: 'menu_delete'
			iconSizeMenu: 17
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.auxRed
			onTriggered: container.removeEntryRequested()
		}
	}
	
	
	
	// Handle hovered link.
	MouseArea {
		anchors.fill:parent	
		//	height: parent.height
		//			width: rectangle.width
		
		acceptedButtons: Qt.RightButton
		propagateComposedEvents:true
		cursorShape: parent.hoveredLink
					 ? Qt.PointingHandCursor
					 : Qt.IBeamCursor
		
		onClicked: mouse.button === Qt.RightButton && messageMenu.open()
	}
	
}
