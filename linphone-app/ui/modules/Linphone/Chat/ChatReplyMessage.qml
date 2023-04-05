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
	id: mainItem
	property ChatMessageModel chatMessageModel
	property ChatMessageModel mainChatMessageModel
	property int availableWidth : parent.width
	property int headerHeight: ChatReplyMessageStyle.header.replyIcon.iconSize
	//property int replyHeight: (chatMessageModel ? replyMessage.height + usernameReplied.implicitHeight + ChatStyle.entry.message.padding * 3 + 3 : 0)
	//property int fitWidth: visible ? Math.max(usernameReplied.implicitWidth + replyMessage.fitWidth , headerArea.fitWidth) + 7 + ChatReplyMessageStyle.padding * 2 : 0
	property int replyHeight: (chatMessageModel ? chatContent.height + usernameReplied.implicitHeight + ChatStyle.entry.message.padding * 3 + 3 : 0)
	property int fitWidth: visible ? Math.max(usernameReplied.implicitWidth, chatContent.bestWidth +ChatReplyMessageStyle.padding*2, headerArea.fitWidth) + 7 + ChatReplyMessageStyle.padding * 2 : 0
	property int fitHeight: visible ? headerHeight + replyHeight : 0
	
	property font customFont : SettingsModel.textMessageFont
	
	visible: mainChatMessageModel && mainChatMessageModel.isReply
	width: availableWidth < 0 || availableWidth > fitWidth ? fitWidth : availableWidth
	height: fitHeight
	onMainChatMessageModelChanged: if( mainChatMessageModel && mainChatMessageModel.replyChatMessageModel) chatMessageModel = mainChatMessageModel.replyChatMessageModel
	
	signal goToMessage(ChatMessageModel message)
	
	ColumnLayout{
		anchors.fill: parent
		spacing: 5
		Row{
			id: headerArea
			property int fitWidth: icon.width + headerText.implicitWidth
			Layout.preferredHeight: headerHeight
			Layout.topMargin: 5
			Icon{
				id: icon
				icon: ChatReplyMessageStyle.header.replyIcon.icon
				iconSize: ChatReplyMessageStyle.header.replyIcon.iconSize
				height: iconSize
				overwriteColor: ChatReplyMessageStyle.header.colorModel.color
				MouseArea{
					anchors.fill: parent
					onClicked: mainItem.goToMessage(mainItem.chatMessageModel)
				}
			}
			Text{
				id: headerText
				height: parent.height
				verticalAlignment: Qt.AlignVCenter
				//: 'Reply' : Header on a message that contains a reply.
				text: qsTr('headerReply')
					  + (chatMessageModel || !mainChatMessageModel? '' : ' - ' + mainChatMessageModel.fromDisplayNameReplyMessage)
				font.family: mainItem.customFont.family
				font.pointSize: Units.dp * (mainItem.customFont.pointSize + ChatReplyMessageStyle.header.pointSizeOffset)
				color: ChatReplyMessageStyle.header.colorModel.color
				MouseArea{
					anchors.fill: parent
					onClicked: mainItem.goToMessage(mainItem.chatMessageModel)
				}
			}
		}
		Rectangle{
			id: replyArea
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.bottomMargin: ChatStyle.entry.message.padding
			Layout.leftMargin: 10
			Layout.rightMargin: 10
			clip: true
			Rectangle{
				id: colorBar
				anchors.left: parent.left
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				width: 15
				radius: 8
				color: chatMessageModel && chatMessageModel.isOutgoing ? ChatReplyMessageStyle.replyArea.outgoingMarkColor.color  : ChatReplyMessageStyle.replyArea.incomingMarkColor.color
				Rectangle{
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					width: 5
					color: ChatReplyMessageStyle.replyArea.backgroundColor.color
				}
			}
			
			radius: 8
			color: ChatReplyMessageStyle.replyArea.backgroundColor.color
			visible: chatMessageModel != undefined
			Text{
				id: usernameReplied
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.topMargin: 3
				
				leftPadding: 2 * ChatStyle.entry.message.padding
				
				text: mainChatMessageModel && mainChatMessageModel.fromDisplayNameReplyMessage
				font.family: mainItem.customFont.family
				font.pointSize: Units.dp * (mainItem.customFont.pointSize + ChatReplyMessageStyle.replyArea.usernamePointSizeOffset)
				font.weight: Font.Bold
				
				color: ChatReplyMessageStyle.replyArea.foregroundColor.color
			}
			ChatContent{
				id: chatContent
				anchors.top: usernameReplied.bottom
				chatMessageModel: mainItem.chatMessageModel
				availableWidth: mainItem.availableWidth
				anchors.left: colorBar.right
				anchors.right: parent.right
				anchors.topMargin: 3
				useTextColor: true
				textColor: ChatReplyMessageStyle.replyArea.foregroundColor.color
				
				fileBackgroundRadius:5
				fileBackgroundColor: ChatReplyMessageStyle.replyArea.fileBackgroundColor.color
				fileBorderWidth:1
			}
		}
	}
}
