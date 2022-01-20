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
// ChatMenu
Item {
	id: container
	property string lastTextSelected
	property ChatMessageModel chatMessageModel
	property int deliveryCount : 0
	property bool deliveryVisible: false
	
	signal deliveryStatusClicked()
	signal removeEntryRequested()
	signal copyAllDone()
	signal copySelectionDone()
	signal replyClicked()
	signal forwardClicked()

	function open(){
		messageMenu.popup()
	}
	
	property string chatTextContent: chatMessageModel && chatMessageModel.content
	
	
	Menu {
		id: messageMenu
		menuStyle : MenuStyle.aux
		MenuItem {
			//: 'Copy all' : Text menu to copy all message text into clipboard
			text: (container.lastTextSelected == '' ? qsTr('menuCopyAll')
													  //: 'Copy' : Text menu to copy selected text in message into clipboard
													:  qsTr('menuCopy'))
			iconMenu: MenuItemStyle.copy.icon
			iconSizeMenu: MenuItemStyle.copy.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			onTriggered: {
				if( container.lastTextSelected == ''){
					Clipboard.text = container.chatTextContent
					container.copyAllDone();
				}else{
					Clipboard.text = container.lastTextSelected
					container.copySelectionDone()
				}
			}
			visible: chatTextContent != ''
		}
		
		MenuItem {
			enabled: TextToSpeech.available
			text: qsTr('menuPlayMe')
			iconMenu: MenuItemStyle.speaker.icon
			iconSizeMenu: MenuItemStyle.speaker.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			onTriggered: TextToSpeech.say(container.chatTextContent)
			visible: chatTextContent != ''
		}
		MenuItem {
			//: 'Forward' : Forward  a message from menu
			text: qsTr('menuForward')
			iconMenu: MenuItemStyle.forward.icon
			iconSizeMenu: MenuItemStyle.forward.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			onTriggered: container.forwardClicked()
		}
		MenuItem {
			//: 'Reply' : Reply to a message from menu
			text: qsTr('menuReply')
			iconMenu: MenuItemStyle.reply.icon
			iconSizeMenu: MenuItemStyle.reply.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			onTriggered: container.replyClicked()
		}
		
		MenuItem {
			//: 'Hide delivery status' : Item menu that lead to IMDN of a message
			text: (deliveryVisible ? qsTr('menuHideDeliveryStatus')
			//: 'Delivery status' : Item menu that lead to IMDN of a message
			: qsTr('menuDeliveryStatus')
			)
			iconMenu: MenuItemStyle.imdn.icon
			iconSizeMenu: MenuItemStyle.imdn.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			visible: container.deliveryCount > 0
			onTriggered: container.deliveryStatusClicked()
		}
		MenuItem {
			//: 'Delete' : Item menu to delete a message
			text: qsTr('menuDelete')
			iconMenu: MenuItemStyle.deleteEntry.icon
			iconSizeMenu: MenuItemStyle.deleteEntry.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.auxRed
			onTriggered: container.removeEntryRequested()
		}
	}
}
