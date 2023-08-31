import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.15

import Common 1.0
import Linphone 1.0

import Units 1.0

// =============================================================================

Rectangle{
	id: mainItem
	
	property ChatReactionProxyModel model
	property var modelData
	
	signal reactionsClicked()
	
	height: visible ? reactionList.height +10 : 0
	width: visible ? reactionLayout.width + 10 : 0
	
	visible: reactionList.count > 0
	property font customFont : SettingsModel.textMessageFont
	property font customEmojiFont : SettingsModel.emojiFont
	
	RowLayout{
		id: reactionLayout
		anchors.centerIn: parent
		ListView{
			id: reactionList
			Layout.preferredWidth: contentItem.childrenRect.width
			Layout.preferredHeight: reactionMetrics.height
			TextMetrics{
				id: reactionMetrics
				text: '😮'
				font.family: mainItem.customEmojiFont.family
				font.pointSize: Units.dp  * mainItem.customEmojiFont.pointSize * 2
			}
			orientation: ListView.Horizontal
			model: mainItem.model
			spacing: 10
			delegate:
				Text{
					width: reactionMetrics.width
					height: reactionList.height
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					font.family: mainItem.customEmojiFont.family
					font.pointSize: Units.dp  * mainItem.customEmojiFont.pointSize * 2
					text: $modelData.body || ''
				}
		}
		
		Text{
			Layout.preferredWidth: contentWidth
			Layout.preferredHeight: reactionList.height
			Layout.alignment: Qt.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			font.family: mainItem.customFont.family
			font.pointSize: Units.dp * mainItem.customFont.pointSize
			visible: mainItem.model && mainItem.model.count != mainItem.model.reactionCount
			
			text: mainItem.model && mainItem.model.reactionCount || ''
		}
	}
	MouseArea{
		anchors.fill: parent
		onClicked: mainItem.reactionsClicked()
	}
}
