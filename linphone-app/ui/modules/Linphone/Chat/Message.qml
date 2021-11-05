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

import ColorsList 1.0

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
	
	signal copyAllDone()
	signal copySelectionDone()
	signal replyClicked()
	signal forwardClicked()
	
	// ---------------------------------------------------------------------------
	
	implicitHeight: message.contentHeight + 
					+ (replyMessage.visible ? replyMessage.contentHeight + 5 : 0)
					+ (ephemeralTimerRow.visible? message.padding * 4 : message.padding * 2) 
					+ (deliveryLayout.visible? deliveryLayout.height : 0)
	
	
	Rectangle {
		id: rectangle
		property int maxWidth: parent.width
		property int dataWidth: Math.max(message.implicitWidth + 2*ChatStyle.entry.message.padding + 10, replyMessage.contentWidth)
		height: parent.height - (deliveryLayout.visible? deliveryLayout.height : 0)
		radius: ChatStyle.entry.message.radius
		width: (
				   ephemeralTimerRow.visible && dataWidth < ephemeralTimerRow.width
				   ? ephemeralTimerRow.width
				   : Math.min(dataWidth, maxWidth)
				   )
		Row{
			id:ephemeralTimerRow
			anchors.right:parent.right
			anchors.bottom:parent.bottom
			anchors.rightMargin : 5
			visible:$chatEntry.isEphemeral
			Text{
				anchors.bottom: parent.bottom	
				anchors.bottomMargin: 5
				text: $chatEntry.ephemeralExpireTime > 0 ? Utils.formatElapsedTime($chatEntry.ephemeralExpireTime) : Utils.formatElapsedTime($chatEntry.ephemeralLifetime)
				color: ChatStyle.ephemeralTimer.timerColor
				font.pointSize: Units.dp * 8
				Timer{
					running:parent.visible
					interval: 1000
					repeat:true
					onTriggered: if($chatEntry.getEphemeralExpireTime() > 0 ) parent.text = Utils.formatElapsedTime($chatEntry.getEphemeralExpireTime())// Use the function
				}
			}
			Icon{
				icon: ChatStyle.ephemeralTimer.icon
				overwriteColor: ChatStyle.ephemeralTimer.timerColor
				iconSize: ChatStyle.ephemeralTimer.iconSize
			}
		}
	
	// ---------------------------------------------------------------------------
	// Message.
	// ---------------------------------------------------------------------------
		Column{
			anchors.left: parent.left
			anchors.right: parent.right
			spacing: 5
			ChatReplyMessage{
				id: replyMessage
				mainChatMessageModel: $chatEntry
				visible: $chatEntry.isReply
				maxWidth: container.width
				height: contentHeight
			}
			TextEdit {
				id: message
				property string lastTextSelected : ''
				property font customFont : SettingsModel.textMessageFont
				
				anchors.left: parent.left
				anchors.right: parent.right
				
				clip: true
				padding: ChatStyle.entry.message.padding
				readOnly: true
				selectByMouse: true
				font.family: customFont.family
				font.pointSize: Units.dp * customFont.pointSize
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
				
				ChatMenu{
					id:chatMenu
					height: parent.height
					width: rectangle.width
					
					lastTextSelected: message.lastTextSelected 
					content: $chatEntry.content
					deliveryCount: deliveryLayout.model.count
					onDeliveryStatusClicked: deliveryLayout.visible = !deliveryLayout.visible
					onRemoveEntryRequested: removeEntry()
					deliveryVisible: deliveryLayout.visible
					
					onCopyAllDone: container.copyAllDone()
					onCopySelectionDone: container.copySelectionDone()
					onReplyClicked: container.replyClicked()
					onForwardClicked: container.forwardClicked()
				}
			}
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
	ChatDeliveries{
		id: deliveryLayout
		anchors.top:rectangle.bottom
		anchors.left:parent.left
		anchors.right:parent.right
		anchors.rightMargin: 50
		
		chatMessageModel: $chatEntry
	}
	
	ActionButton {
		anchors.left:rectangle.right
		anchors.leftMargin: -10
		anchors.top:rectangle.top
		anchors.topMargin: 5
		
		height: ChatStyle.entry.menu.iconSize
		isCustom: true
		backgroundRadius: 8
		
		colorSet : ChatStyle.entry.menu
		visible: isHoverEntry()
		
		onClicked: chatMenu.open()
	}
}
