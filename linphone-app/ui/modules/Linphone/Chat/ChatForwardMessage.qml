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
	property ChatMessageModel mainChatMessageModel
	property int availableWidth : parent.width
	property int fitWidth:  visible ? headerArea.fitWidth + 7 + ChatForwardMessageStyle.padding * 2 : 0
	property int fitHeight: visible ? icon.height + 5 : 0
	property font customFont : SettingsModel.textMessageFont
	
	visible: mainChatMessageModel && mainChatMessageModel.isForward
	width: availableWidth > fitWidth ? fitWidth : availableWidth
	height: fitHeight
	
	ColumnLayout{
		anchors.fill: parent
		spacing: 5
		Row{
			id: headerArea
			property int fitWidth: icon.width + headerText.implicitWidth
			Layout.fillHeight: true
			Layout.topMargin: 5
			Icon{
				id: icon
				icon: ChatForwardMessageStyle.header.forwardIcon.icon
				iconSize: ChatForwardMessageStyle.header.forwardIcon.iconSize
				height: iconSize
				overwriteColor: ChatForwardMessageStyle.header.colorModel.color
			}
			Text{
				id: headerText
				height: icon.height
				verticalAlignment: Qt.AlignVCenter
				// Anonymized forward : do not get display name, this is wanted.
				//property string forwardInfo: mainChatMessageModel ? mainChatMessageModel.getForwardInfoDisplayName : ''
				//: 'Forwarded' : Header on a message that contains a forward.
				text: qsTr('Forwarded')// + (forwardInfo ? ' : ' +forwardInfo : '')
				font.family: mainItem.customFont.family
				font.pointSize: Units.dp * (mainItem.customFont.pointSize + ChatForwardMessageStyle.header.pointSizeOffset)
				color: ChatForwardMessageStyle.header.colorModel.color
			}
		}
	}
}
