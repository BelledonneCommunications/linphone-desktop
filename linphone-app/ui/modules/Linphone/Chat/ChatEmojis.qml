import QtQuick 2.7
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3


import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0
import UtilsCpp 1.0

import Units 1.0

import 'Chat.js' as Logic

// =============================================================================
Item{
	id: mainItem
	visible: false
	height: visible ? 150 : 0
	//Layout.preferredHeight: visible ? 150 : 0
	//Layout.maximumHeight:  visible ? 150 : 0
	signal emojiClicked(var emoji)
	//onHeightChanged: console.log(height)
	onVisibleChanged: if(visible) loader.active = true
	Loader{
		id: loader
		property bool toLoad : false
		anchors.fill: parent
		active: false
		asynchronous: true
		//visible: status == Loader.Ready
		sourceComponent:
			Flickable {
			id: emojisArea
			ScrollBar.vertical: ForceScrollBar {visible: emojisArea.height < emojiPicker.height}
			boundsBehavior: Flickable.StopAtBounds
			contentHeight: emojiPicker.height
			contentWidth: width - ScrollBar.vertical.width
			flickableDirection: Flickable.VerticalFlick 
			clip: true
			anchors.fill: parent
			//Layout.fillHeight: true
			//Layout.fillWidth: true
			EmojiPicker {
				id: emojiPicker
				width: emojisArea.contentWidth
				onEmojiClicked: mainItem.emojiClicked(emoji)
			}
		}
	}
}
