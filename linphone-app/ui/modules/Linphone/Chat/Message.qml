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
	
	// ---------------------------------------------------------------------------
	
	property alias backgroundColor: rectangle.color
	property alias color: message.color
	property alias pointSize: message.font.pointSize
	
	default property alias _content: content.data
	
	// ---------------------------------------------------------------------------
	
	implicitHeight: message.contentHeight 
						+ (ephemeralTimerRow.visible? message.padding * 4 : message.padding * 2) 
						+ (deliveryLayout.visible? deliveryLayout.height : 0)
	
	Rectangle {
		id: rectangle
		
		height: parent.height - (deliveryLayout.visible? deliveryLayout.height : 0)
		radius: ChatStyle.entry.message.radius
		width: (
				   message.contentWidth < ephemeralTimerRow.width
				   ? ephemeralTimerRow.width
				   : message.contentWidth < parent.width
					 ? message.contentWidth
					 : parent.width
				   ) + message.padding * 2
		Row{
			id:ephemeralTimerRow
			anchors.right:parent.right
			anchors.bottom:parent.bottom	
			anchors.bottomMargin: 5
			anchors.rightMargin : 5
			visible:$chatEntry.isEphemeral
			spacing:5
			Text{
				visible : $chatEntry.ephemeralExpireTime > 0
				text: Utils.formatElapsedTime($chatEntry.ephemeralExpireTime)
				color:"#FF5E00"
				font.pointSize: Units.dp * 8
				Timer{
					running:parent.visible
					interval: 1000
					repeat:true
					onTriggered: parent.text = Utils.formatElapsedTime($chatEntry.getEphemeralExpireTime())// Use the function
				}
			}
			Icon{
				icon:'timer'
				iconSize: 15
			}
		}
	}
	
	// ---------------------------------------------------------------------------
	// Message.
	// ---------------------------------------------------------------------------
	
	TextEdit {
		id: message
		property string lastTextSelected : ''
		
		anchors {
			left: container.left
			right: container.right
		}
		
		clip: true
		padding: ChatStyle.entry.message.padding
		readOnly: true
		selectByMouse: true
		text: Utils.encodeTextToQmlRichFormat($chatEntry.content, {
												  imagesHeight: ChatStyle.entry.message.images.height,
												  imagesWidth: ChatStyle.entry.message.images.width
											  })
		
		// See http://doc.qt.io/qt-5/qml-qtquick-text.html#textFormat-prop
		// and http://doc.qt.io/qt-5/richtext-html-subset.html
		textFormat: Text.RichText // To supports links and imgs.
		wrapMode: TextEdit.Wrap
		
		onCursorRectangleChanged: Logic.ensureVisible(cursorRectangle)
		onLinkActivated: Qt.openUrlExternally(link)
		onSelectedTextChanged:if(selectedText != '') lastTextSelected = selectedText
		onActiveFocusChanged: {
			if(activeFocus)
				lastTextSelected = ''
			deselect()
		}
		
		
		Menu {
			id: messageMenu
			menuStyle : MenuStyle.aux
			MenuItem {
				//: 'Copy all' : Text menu to copy all message text into clipboard
				text: (message.lastTextSelected == '' ? qsTr('menuCopyAll')
				//: 'Copy' : Text menu to copy selected text in message into clipboard
				:  qsTr('menuCopy'))
				iconMenu: 'menu_copy_text'
				iconSizeMenu: 17
				iconLayoutDirection: Qt.RightToLeft
				menuItemStyle : MenuItemStyle.aux
				onTriggered: Clipboard.text = (message.lastTextSelected == '' ? $chatEntry.content : message.lastTextSelected)
			}
			
			MenuItem {
				enabled: TextToSpeech.available
				text: qsTr('menuPlayMe')
				iconMenu: 'speaker'
				iconSizeMenu: 17
				iconLayoutDirection: Qt.RightToLeft
				menuItemStyle : MenuItemStyle.aux
				onTriggered: TextToSpeech.say($chatEntry.content)
			}
			MenuItem {
				//: 'Delivery status' : Item menu that lead to IMDN of a message
				text: qsTr('menuDeliveryStatus')
				iconMenu: 'menu_imdn_info'
				iconSizeMenu: 17
				iconLayoutDirection: Qt.RightToLeft
				menuItemStyle : MenuItemStyle.aux
				visible: deliveryLayout.model.count > 0
				onTriggered: deliveryLayout.visible = !deliveryLayout.visible
			}
			MenuItem {
				//: 'Delete' : Item menu to delete a message
				text: qsTr('menuDelete')
				iconMenu: 'menu_delete'
				iconSizeMenu: 17
				iconLayoutDirection: Qt.RightToLeft
				menuItemStyle : MenuItemStyle.auxRed
				onTriggered: removeEntry()
			}
		}

		
		
		// Handle hovered link.
		MouseArea {
			height: parent.height
			width: rectangle.width
			
			acceptedButtons: Qt.RightButton
			cursorShape: parent.hoveredLink
						 ? Qt.PointingHandCursor
						 : Qt.IBeamCursor
			
			onClicked: mouse.button === Qt.RightButton && messageMenu.open()
		}
	}
	
	// ---------------------------------------------------------------------------
	// Extra content.
	// ---------------------------------------------------------------------------
	
	Item {
		id: content
		
		anchors {
			left: rectangle.right
			leftMargin: ChatStyle.entry.message.extraContent.leftMargin
		}
	}
	GridView{
		id: deliveryLayout
		anchors.top:rectangle.bottom
		anchors.left:parent.left
		anchors.right:parent.right
		anchors.rightMargin: 50
		//height: visible ? ChatStyle.composingText.height*container.proxyModel.composers.length : 0
		height: visible ? (ChatStyle.composingText.height-5)*deliveryLayout.model.count : 0
		cellWidth: parent.width; cellHeight: ChatStyle.composingText.height-5
		visible:false
		model: ParticipantImdnStateProxyModel{
			id: imdnStatesModel
			chatMessageModel: $chatEntry
		}
		function getText(state, displayName, stateChangeTime){
			if(state == LinphoneEnums.ChatMessageStateDelivered)
				//: 'Send to %1 - %2' Little message to indicate the state of a message
				//~ Context %1 is someone, %2 is a date/time. The state is that the message has been sent but not received.
				return qsTr('deliveryDelivered').arg(displayName).arg(stateChangeTime)
			else if(state == LinphoneEnums.ChatMessageStateDeliveredToUser)
				//: 'Retrieved by %1 - %2' Little message to indicate the state of a message
				//~ Context %1 is someone, %2 is a date/time. The state is that the message has been retrieved
				return qsTr('deliveryDeliveredToUser').arg(displayName).arg(stateChangeTime)
			else if(state == LinphoneEnums.ChatMessageStateDisplayed)
				//: 'Read by %1 - %2' Little message to indicate the state of a message
				//~ Context %1 is someone, %2 is a date/time. The state that the message has been read.
				return qsTr('deliveryDisplayed').arg(displayName).arg(stateChangeTime)
			else if(state == LinphoneEnums.ChatMessageStateNotDelivered)
				//: "%1 have nothing received" Little message to indicate the state of a message
				//~ Context %1 is someone. The state is that the message hasn't been delivered.
				return qsTr('deliveryNotDelivered').arg(displayName)
			else return ''
		}
		delegate:Text{
			height:ChatStyle.composingText.height-5
			width:parent.width
			text:deliveryLayout.getText(modelData.state, modelData.displayName, UtilsCpp.toDateTimeString(modelData.stateChangeTime))
			color:"#B1B1B1"
			font.pointSize: Units.dp * 8
			elide: Text.ElideMiddle
		}
	}
}
