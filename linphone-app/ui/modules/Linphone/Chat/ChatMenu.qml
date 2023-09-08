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
import ConstantsCpp 1.0
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
	property bool isCallEvent: false	// the menu point to an event
	
	signal deliveryStatusClicked()
	signal removeEntryRequested()
	signal copyAllDone()
	signal copySelectionDone()
	signal replyClicked()
	signal forwardClicked()
	signal addContactClicked(string contactAddress)
	signal viewContactClicked(string contactAddress)

	function open(){
		messageMenu.popup()
	}
	
	property string chatTextContent: chatMessageModel && chatMessageModel.content
	property bool isContact: (chatMessageModel && chatMessageModel.contactModel) || false
	
	
	Menu {
		id: messageMenu
		menuStyle : MenuStyle.aux
		RowLayout{
			id: reactionBar
			property font customFont : SettingsModel.emojiFont
			width: parent.width
			height: 50
			anchors.margins: 10	// Let parent border displayed
			spacing: 0
			
			Repeater{
					model: ConstantsCpp.reactionsList
					delegate: MenuItem{
						isTabBar: true
						Layout.fillWidth: true
						Layout.fillHeight: true
						Layout.topMargin: 5
						Layout.bottomMargin: 5
						Layout.leftMargin: 2
						Layout.rightMargin: 2
						
						radius: messageMenu.radius
						down: chatMessageModel && modelData && modelData == chatMessageModel.myReaction
						onTriggered: {
									chatMessageModel.sendChatReaction(modelData)
									messageMenu.close()
								}
						Text{
							id: bodyItem
							anchors.fill: parent
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
							text:  modelData
							font.family: reactionBar.customFont.family
							font.pointSize: Units.dp  * reactionBar.customFont.pointSize * 2
						}
					}
				}
			
		}
		
		MenuItem {
			//: 'Copy all' : Text menu to copy all message text into clipboard
			text: (container.lastTextSelected == '' ? qsTr('menuCopyAll')
													  //: 'Copy' : Text menu to copy selected text in message into clipboard
													:  qsTr('menuCopy'))
			iconMenu: MenuItemStyle.copy.icon
			iconSizeMenu: MenuItemStyle.entry.iconSize
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
			iconSizeMenu: MenuItemStyle.entry.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			onTriggered: TextToSpeech.say(container.chatTextContent)
			visible: chatTextContent != ''
		}
		MenuItem {
			//: 'Forward' : Forward  a message from menu
			text: qsTr('menuForward')
			iconMenu: MenuItemStyle.forward.icon
			iconSizeMenu: MenuItemStyle.entry.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			onTriggered: container.forwardClicked()
			visible: !isCallEvent
		}
		MenuItem {
			//: 'Reply' : Reply to a message from menu
			text: qsTr('menuReply')
			iconMenu: MenuItemStyle.reply.icon
			iconSizeMenu: MenuItemStyle.entry.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			onTriggered: container.replyClicked()
			visible: !isCallEvent
		}
		
		MenuItem {
			//: 'Hide delivery status' : Item menu that lead to IMDN of a message
			text: (deliveryVisible ? qsTr('menuHideDeliveryStatus')
			//: 'Delivery status' : Item menu that lead to IMDN of a message
			: qsTr('menuDeliveryStatus')
			)
			iconMenu: MenuItemStyle.imdn.icon
			iconSizeMenu: MenuItemStyle.entry.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			visible: container.deliveryCount > 0
			onTriggered: container.deliveryStatusClicked()
		}
		MenuItem {
			text: container.isContact
					//: 'View contact' : Menu item to view the contact.
					? qsTr('menuViewContact')
					//: 'Add to contacts' : Menu item to add the contact to address book.
					: qsTr('menuAddContact')
			iconMenu: container.isContact ? MenuItemStyle.contact.view : MenuItemStyle.contact.add
			iconSizeMenu: MenuItemStyle.entry.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.aux
			visible: container.chatMessageModel && !container.chatMessageModel.isOutgoing
			onTriggered: container.isContact ? container.viewContactClicked(container.chatMessageModel.fromSipAddress) : container.addContactClicked(container.chatMessageModel.fromSipAddress)
		}
		MenuItem {
			//: 'Delete' : Item menu to delete a message
			text: qsTr('menuDelete')
			iconMenu: MenuItemStyle.deleteEntry.icon
			iconSizeMenu: MenuItemStyle.entry.iconSize
			iconLayoutDirection: Qt.RightToLeft
			menuItemStyle : MenuItemStyle.auxError
			onTriggered: container.removeEntryRequested()
		}
	}
}
