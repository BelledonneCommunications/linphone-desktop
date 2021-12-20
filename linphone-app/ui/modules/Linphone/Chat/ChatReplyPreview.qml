import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0
import UtilsCpp 1.0

import Units 1.0

import 'Chat.js' as Logic

// =============================================================================

Rectangle{
	id: replyPreviewBlock
	property ChatRoomModel chatRoomModel
	
	Layout.preferredHeight: Math.min(messageContentsList.height + replyPreviewHeaderArea.implicitHeight + 15, parent.maxHeight)
	
	property int leftMargin: textArea.textLeftMargin
	property int rightMargin: textArea.textRightMargin
	
	color: ChatStyle.replyPreview.backgroundColor
	radius: 10
	state: chatRoomModel && chatRoomModel.reply ? 'showed' : 'hidden'
	// Remove bottom corners				
	clip: false
	function hide(){
		state = 'hidden'
	}
	MouseArea{// Block mouse events
		anchors.fill: parent
	}
	Rectangle{
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		height: parent.radius
		color: parent.color
	}
	//-------------------------
	ColumnLayout{
		anchors.fill: parent
		anchors.leftMargin: replyPreviewBlock.leftMargin
		anchors.rightMargin: replyPreviewBlock.rightMargin
		anchors.bottomMargin: 5
		spacing: 0
		RowLayout{
			id: replyPreviewHeaderArea
			Layout.fillWidth: true
			Layout.preferredHeight: replyPreviewTitleText.implicitHeight
			Layout.topMargin: 10
			spacing: 5
			Icon{
				icon: ChatStyle.replyPreview.icon
				overwriteColor: ChatStyle.replyPreview.iconColor
				iconSize: 20
			}
			Text{
				id: replyPreviewTitleText
				Layout.fillWidth: true
				Layout.preferredHeight: implicitHeight
				//: 'Reply to %1' : Title for a reply preview to know who said what.
				text: replyPreviewBlock.chatRoomModel && replyPreviewBlock.chatRoomModel.reply ?  qsTr('titleReply').arg(replyPreviewBlock.chatRoomModel.reply.fromDisplayName) : ''
				font.pointSize: ChatStyle.replyPreview.headerPointSize
				font.weight: Font.Bold
				color: ChatStyle.replyPreview.headerTextColor
			}
		}
		Flickable {
			id: replyPreviewTextArea
			ScrollBar.vertical: ForceScrollBar {visible: replyPreviewTextArea.height < messageContentsList.implicitHeight}
			boundsBehavior: Flickable.StopAtBounds
			clip: true
			contentHeight: messageContentsList.height
			contentWidth: width - ScrollBar.vertical.width
			flickableDirection: Flickable.VerticalFlick 
			
			Layout.fillHeight: true
			Layout.fillWidth: true
			ListView {
				id: messageContentsList
				anchors.left: parent.left
				anchors.right: parent.right
				model: ContentProxyModel{
					chatMessageModel: replyPreviewBlock.chatRoomModel && replyPreviewBlock.chatRoomModel.reply
				}
				height: contentHeight
				
				delegate: ChatContent{
					contentModel: modelData
					textFont.pointSize: Units.dp * (SettingsModel.textMessageFont.pointSize - 2)
				}
			}
		}
	}
	ActionButton{
		anchors.right:parent.right
		anchors.rightMargin: 14
		anchors.verticalCenter: parent.verticalCenter
		height: ChatStyle.replyPreview.closeButton.iconSize
		isCustom: true
		backgroundRadius: 90
		colorSet: ChatStyle.replyPreview.closeButton
		
		onClicked: chatRoomModel.reply = null
	}
	states: [
		State {
			name: "hidden"
			PropertyChanges { target: replyPreviewBlock; opacity: 0 ; visible: false }
		},
		State {
			name: "showed"
			PropertyChanges { target: replyPreviewBlock; opacity: 1 ; visible: true}
		}
	]
	transitions: [
		Transition {
			from: "*"; to: "showed"
			SequentialAnimation{
				ScriptAction{ script: replyPreviewBlock.visible = true }
				NumberAnimation{ properties: "opacity"; easing.type: Easing.OutBounce; duration: 500 }
			}
		},
		Transition {
			from: "*"; to: "hidden"
			SequentialAnimation{
				NumberAnimation{ properties: "opacity"; duration: 250 }
				ScriptAction{ script: replyPreviewBlock.visible = false }
			}
		}
	]
}	