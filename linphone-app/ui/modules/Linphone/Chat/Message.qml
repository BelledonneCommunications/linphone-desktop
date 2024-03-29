import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.15

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
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Item {
	id: container
	
	// ---------------------------------------------------------------------------
	
	property alias backgroundColorModel: rectangle.colorModel
	property bool isHovering : false
	default property alias _content: content.data
	property bool isTopGrouped: false
	property bool isBottomGrouped: false
	
	// ---------------------------------------------------------------------------
	
	signal copyAllDone()
	signal copySelectionDone()
	signal replyClicked()
	signal forwardClicked()
	signal goToMessage(ChatMessageModel message)
	signal conferenceIcsCopied()
	signal addContactClicked(string contactAddress)
	signal viewContactClicked(string contactAddress)
	signal reactionsClicked(ChatMessageModel message)
	
	// ---------------------------------------------------------------------------
	property string lastTextSelected
	implicitHeight: (deliveryLayout.visible? deliveryLayout.height : 0) +(ephemeralTimerRow.visible? 16 : 0) + chatContent.height + (reactionLoader.active?reactionLoader.height-10 : 0)
	Rectangle {
		id: rectangle
		property int availableWidth: parent.width
		property bool ephemeral : $chatEntry.isEphemeral
		property var colorModel:{'color': 'transparent'}
		
		anchors.left: !$chatEntry.isOutgoing ? parent.left : undefined
		anchors.right: $chatEntry.isOutgoing ? parent.right : undefined
		
		height: parent.height - (deliveryLayout.visible? deliveryLayout.height : 0) - (reactionLoader.active ? reactionLoader.height-10 : 0)
		radius: ChatStyle.entry.message.radius
		clip: false
		color: colorModel.color
		width: (//implicitWidth
				   ephemeralTimerRow.visible && (chatContent.bestWidth < ephemeralTimerRow.width + 2*ChatStyle.entry.message.padding)
				   ? ephemeralTimerRow.width + 2*ChatStyle.entry.message.padding
				   : Math.min(chatContent.bestWidth, availableWidth)
				   )
		
		// ---------------------------------------------------------------------------
		// Message.
		// ---------------------------------------------------------------------------
		Rectangle{
			visible: container.isTopGrouped || container.isBottomGrouped
			color: parent.color
			anchors.left: !$chatEntry.isOutgoing ? parent.left : undefined
			anchors.right: $chatEntry.isOutgoing ? parent.right : undefined
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.topMargin: container.isTopGrouped ? 0 : parent.radius
			anchors.bottomMargin: container.isBottomGrouped ? 0 : parent.radius
			width: parent.radius
		}
		ChatFullContent{
			id: chatContent
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			chatMessageModel: $chatEntry
			availableWidth: rectangle.availableWidth
			onLastTextSelectedChanged: container.lastTextSelected= lastTextSelected
			onGoToMessage: container.goToMessage(message)
			onRightClicked: chatMenu.open()
			onConferenceIcsCopied: container.conferenceIcsCopied()
			onIsFileHoveringChanged: menuButton.visible = !isFileHovering
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
				color: ChatStyle.ephemeralTimer.timerColor.color
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
				overwriteColor: ChatStyle.ephemeralTimer.timerColor.color
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
			bottom: rectangle.bottom
			leftMargin: ChatStyle.entry.message.extraContent.leftMargin
		}
		
	}
	Loader{
		id: reactionLoader
		anchors.top: rectangle.bottom
		anchors.left: !$chatEntry.isOutgoing ? rectangle.left : undefined
		anchors.right: $chatEntry.isOutgoing ? rectangle.right : undefined
		anchors.topMargin: -10
		anchors.leftMargin: 5
		anchors.rightMargin: 5
		ChatReactionProxyModel{
			id: chatReactionProxyModel
			chatMessageModel: $chatEntry
		}
		active: chatReactionProxyModel.count > 0
		asynchronous: true
		sourceComponent: ChatReactions{
			color: rectangle.color
			radius: rectangle.radius
			model: chatReactionProxyModel
			onReactionsClicked: container.reactionsClicked($chatEntry)
		}
	}
	ChatDeliveries{
		id: deliveryLayout
		anchors.top: reactionLoader.active ? reactionLoader.bottom : rectangle.bottom
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
		visible: container.isHovering
		
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
		onAddContactClicked: container.addContactClicked(contactAddress)
		onViewContactClicked: container.viewContactClicked(contactAddress)
	}
}
