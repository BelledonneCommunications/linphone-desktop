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
	
	default property alias _content: content.data
	
	// ---------------------------------------------------------------------------
	
	signal copyAllDone()
	signal copySelectionDone()
	signal replyClicked()
	signal forwardClicked()
	signal goToMessage(ChatMessageModel message)
	signal conferenceIcsCopied()
	
	// ---------------------------------------------------------------------------
	property string lastTextSelected
	implicitHeight: (deliveryLayout.visible? deliveryLayout.height : 0) +(ephemeralTimerRow.visible? 16 : 0) + messageData.height
	
	Rectangle {
		id: rectangle
		property int maxWidth: parent.width
		property int dataWidth: maxWidth
		property bool ephemeral : $chatEntry.isEphemeral
		function updateWidth(){
			var maxWidth = Math.max(forwardMessage.fitWidth, replyMessage.fitWidth)
			for(var child in messageContentsList.contentItem.children) {
				var a = messageContentsList.contentItem.children[child].fitWidth
				if(a)
					maxWidth = Math.max(maxWidth,a)
			}
			rectangle.dataWidth = maxWidth
		}
		height: parent.height - (deliveryLayout.visible? deliveryLayout.height : 0)
		radius: ChatStyle.entry.message.radius
		clip: false
		width: (
				   ephemeralTimerRow.visible && dataWidth < ephemeralTimerRow.width + 2*ChatStyle.entry.message.padding
				   ? ephemeralTimerRow.width + 2*ChatStyle.entry.message.padding
				   : Math.min(dataWidth, maxWidth)
				   )
		// ---------------------------------------------------------------------------
		// Message.
		// ---------------------------------------------------------------------------
		
		Column{
			id: messageData
			anchors.left: parent.left
			anchors.right: parent.right
			spacing: 0
			ChatForwardMessage{
				id: forwardMessage
				mainChatMessageModel: $chatEntry
				visible: $chatEntry.isForward
				maxWidth: container.width
				onFitWidthChanged:{
					rectangle.updateWidth()
				}
			}
			ChatReplyMessage{
				id: replyMessage
				z: 1
				mainChatMessageModel: $chatEntry
				visible: $chatEntry.isReply
				maxWidth: container.width
				onFitWidthChanged:{
					rectangle.updateWidth()
				}
				onGoToMessage: container.goToMessage(message)
				onConferenceIcsCopied: container.conferenceIcsCopied()
			}
			ListView {
				id: messageContentsList
				anchors.left: parent.left
				anchors.right: parent.right
				visible: count > 0
				spacing: 0
				clip: false
				model: ContentProxyModel{
					chatMessageModel: $chatEntry
				}
				height: contentHeight
				boundsBehavior: Flickable.StopAtBounds
				interactive: false
				delegate: 
					ChatContent{
						maxWidth: container.width
						contentModel: $modelData
						onFitWidthChanged:{
							rectangle.updateWidth()			
						}
						onLastTextSelectedChanged: container.lastTextSelected= lastTextSelected
						onRightClicked: chatMenu.open()
						onConferenceIcsCopied: container.conferenceIcsCopied()
						onFileIsHoveringChanged: menuButton.visible = !fileIsHovering
						Rectangle{
							anchors.left: parent.left
							anchors.right: parent.right
							color: ChatStyle.entry.separator.color
							height: visible ? ChatStyle.entry.separator.width : 0
							visible: (index !== (messageContentsList.count - 1)) 
						}
					}
			}
		}
		Row{
			id:ephemeralTimerRow
			anchors.right:parent.right
			anchors.bottom:parent.bottom
			anchors.rightMargin : 5
			visible:$chatEntry.isEphemeral
			Text{
				id: ephemeralText
				anchors.bottom: parent.bottom	
				anchors.bottomMargin: 5
				text: $chatEntry.ephemeralExpireTime > 0 ? Utils.formatElapsedTime($chatEntry.ephemeralExpireTime) : Utils.formatElapsedTime($chatEntry.ephemeralLifetime)
				color: ChatStyle.ephemeralTimer.timerColor
				font.pointSize: Units.dp * 8
				Timer{
					running:parent.visible
					interval: 1000
					repeat:true
					onTriggered: if($chatEntry && $chatEntry.getEphemeralExpireTime() > 0 ) parent.text = Utils.formatElapsedTime($chatEntry.getEphemeralExpireTime())// Use the function
				}
			}
			Icon{
				anchors.verticalCenter: ephemeralText.verticalCenter
				icon: ChatStyle.ephemeralTimer.icon
				overwriteColor: ChatStyle.ephemeralTimer.timerColor
				iconSize: ChatStyle.ephemeralTimer.iconSize
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
		id: menuButton
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
	ChatMenu{
		id:chatMenu
		height: parent.height
		width: rectangle.width
		chatMessageModel: $chatEntry
		
		lastTextSelected: container.lastTextSelected 
		deliveryCount: deliveryLayout.imdnStatesModel.count
		onDeliveryStatusClicked: deliveryLayout.visible = !deliveryLayout.visible
		onRemoveEntryRequested: removeEntry()
		deliveryVisible: deliveryLayout.visible
		
		onCopyAllDone: container.copyAllDone()
		onCopySelectionDone: container.copySelectionDone()
		onReplyClicked: container.replyClicked()
		onForwardClicked: container.forwardClicked()
	}
}
