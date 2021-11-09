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
	property ChatMessageModel replyChatMessageModel
	onReplyChatMessageModelChanged: if(replyChatMessageModel) replyPreviewBlock.state = "showed"
	
	Layout.preferredHeight: Math.min(replayPreviewText.implicitHeight + replyPreviewHeaderArea.implicitHeight + 10, parent.maxHeight)
	
	property int leftMargin: textArea.textLeftMargin
	property int rightMargin: textArea.textRightMargin
	
	color: ChatStyle.replyPreview.backgroundColor
	radius: 10
	state: "hidden"
	visible: container.replyChatMessageModel
// Remove bottom corners				
	clip: false
	function hide(){
		state = 'hidden'
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
				text: container.replyChatMessageModel ?  qsTr('titleReply').arg(container.replyChatMessageModel.fromDisplayName) : ''
				font.pointSize: ChatStyle.replyPreview.headerPointSize
				font.weight: Font.Bold
				color: ChatStyle.replyPreview.headerTextColor
			}
		}
		Flickable {
			id: replayPreviewTextArea
			ScrollBar.vertical: ForceScrollBar {visible: replayPreviewTextArea.height < replayPreviewText.implicitHeight}
			boundsBehavior: Flickable.StopAtBounds
			clip: true
			contentHeight: replayPreviewText.implicitHeight
			contentWidth: width - ScrollBar.vertical.width
			flickableDirection: Flickable.VerticalFlick 
			
			Layout.fillHeight: true
			Layout.fillWidth: true
		
			TextEdit {
				id: replayPreviewText
				property font customFont : SettingsModel.textMessageFont
				
				anchors.left: parent.left
				anchors.right: parent.right
				clip: true
				padding: ChatStyle.entry.message.padding
				readOnly: true
				selectByMouse: true
				font.family: customFont.family
				font.pointSize: Units.dp * (customFont.pointSize - 2)
				text: replyChatMessageModel ? Utils.encodeTextToQmlRichFormat(replyChatMessageModel.content, {
														  imagesHeight: ChatStyle.entry.message.images.height,
														  imagesWidth: ChatStyle.entry.message.images.width
													  })
													: ''
				textFormat: Text.RichText // To supports links and imgs.
				wrapMode: TextEdit.Wrap
				
				onLinkActivated: Qt.openUrlExternally(link)
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
		
		onClicked: parent.hide()
	}
	states: [
		 State {
			 name: "hidden"
			 PropertyChanges { target: replyPreviewBlock; opacity: 0 }
		 },
		 State {
			 name: "showed"
			 PropertyChanges { target: replyPreviewBlock; opacity: 1 }
		 }
	 ]
	 transitions: [
		 Transition {
			 from: "*"; to: "showed"
			 SequentialAnimation{
				NumberAnimation{ properties: "opacity"; easing.type: Easing.OutBounce; duration: 500 }
			}
		 },
		 Transition {
			SequentialAnimation{
				NumberAnimation{ properties: "opacity"; duration: 250 }
				ScriptAction{ script: container.replyChatMessageModel = null }
			}
		}
	]
}	