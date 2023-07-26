import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0

import UtilsCpp 1.0
// =============================================================================

Controls.ItemDelegate {
	id: item
	
	property var container
	property var flattenedModel
	property var itemIcon
	
	default property alias _content: content.data
	property alias leftActionsLoader: leftActionsLoader
	
	hoverEnabled: true
	background: Rectangle {
		color: item.hovered
			   ? CommonItemDelegateStyle.color.hovered.color
			   : CommonItemDelegateStyle.color.normal.color
		Rectangle {
			anchors.left: parent.left
			color: CommonItemDelegateStyle.indicator.colorModel.color
			
			height: parent.height
			width: CommonItemDelegateStyle.indicator.width
			
			visible: item.hovered
		}
		
		Rectangle {
			anchors.bottom: parent.bottom
			color: CommonItemDelegateStyle.separator.colorModel.color
			
			height: CommonItemDelegateStyle.separator.height
			width: parent.width
			
			visible: container.count !== index + 1
		}
	}
	
	contentItem: RowLayout {
		spacing: CommonItemDelegateStyle.contentItem.spacing
		width: item.width
		
		Icon {
			icon: item.itemIcon
			iconSize: CommonItemDelegateStyle.contentItem.iconSize
			
			visible: icon.length > 0
		}
		Loader{
			id: leftActionsLoader
		}
		Text {
			Layout.fillWidth: true
			
			color: CommonItemDelegateStyle.contentItem.text.colorModel.color
			elide: Text.ElideRight
			
			font {
				bold: container.currentIndex === index
				pointSize: CommonItemDelegateStyle.contentItem.text.pointSize
			}
			
			text: UtilsCpp.toDisplayString(item.flattenedModel[container.textRole] || modelData, SettingsModel.sipDisplayMode)
		}
		
		Item {
			id: content
			
			Layout.preferredWidth: CommonItemDelegateStyle.contentItem.iconSize
			Layout.preferredHeight: CommonItemDelegateStyle.contentItem.iconSize
		}
	}
}
