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
	property int maxWidth : parent.width
	property int headerHeight: ChatReplyMessageStyle.header.replyIcon.iconSize
	property int replyHeight: (chatMessageModel ? replyMessage.height + usernameReplied.implicitHeight + ChatStyle.entry.message.padding * 3 + 3 : 0)
	property int fitWidth: visible ? Math.max(usernameReplied.implicitWidth + replyMessage.fitWidth , headerArea.fitWidth) + 7 + ChatReplyMessageStyle.padding * 2 : 0
	property int fitHeight: visible ? headerHeight + replyHeight : 0
	
	property font customFont : SettingsModel.textMessageFont
	
	visible: mainChatMessageModel && mainChatMessageModel.isReply
	width: maxWidth < 0 || maxWidth > fitWidth ? fitWidth : maxWidth
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
				overwriteColor: ChatReplyMessageStyle.header.color
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
				color: ChatReplyMessageStyle.header.color
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
			Rectangle{
				anchors.left: parent.left
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				width: 7
				color: chatMessageModel && chatMessageModel.isOutgoing ? ChatReplyMessageStyle.replyArea.outgoingMarkColor  : ChatReplyMessageStyle.replyArea.incomingMarkColor
			}
			
			radius: 5
			color: ChatReplyMessageStyle.replyArea.backgroundColor
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
				
				color: ChatReplyMessageStyle.replyArea.foregroundColor
			}
			ScrollableListView {
				id: replyMessage
				property int fitWidth : 0
				hideScrollBars: true
				anchors.top: usernameReplied.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.topMargin: 3
				anchors.leftMargin: 5
				
				function updateWidth(){
					var maxWidth = 0
					for(var child in replyMessage.contentItem.children) {
						var a = replyMessage.contentItem.children[child].fitWidth
						if(a)
							maxWidth = Math.max(maxWidth,a)
					}
					fitWidth = maxWidth
				}
				
				model: ContentProxyModel{
					chatMessageModel: mainItem.chatMessageModel
				}
				Timer{// Delay to avoid binding loops
					id:delayUpdate
					interval:10
					onTriggered: replyMessage.height = replyMessage.contentHeight
				}
				onContentHeightChanged: delayUpdate.restart()
				//height: contentHeight
				
				delegate: ChatContent{
					contentModel: modelData
					textColor: ChatReplyMessageStyle.replyArea.foregroundColor
					textFont.pointSize: Units.dp * (customFont.pointSize + ChatReplyMessageStyle.replyArea.pointSizeOffset)
					textFont.weight: Font.Light
					onFitWidthChanged:{
						replyMessage.updateWidth()			
					}
					Rectangle{
							anchors.left: parent.left
							anchors.right: parent.right
							color: ChatStyle.entry.separator.color
							height: visible ? ChatStyle.entry.separator.width : 0
							visible: (index !== (replyMessage.count - 1)) 
						}
				}
			}
		}
	}
}
