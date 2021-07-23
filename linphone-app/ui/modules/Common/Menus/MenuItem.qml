import QtQuick 2.7
import QtQuick.Controls 2.2  as Controls

import Common 1.0

import Common.Styles 1.0

// =============================================================================

// Using MenuItem.icon doesn't seem to work as of 07/2021
// Workaround : Implement own Icon

Controls.MenuItem {
	id: button
	property alias iconMenu : iconArea.icon
	property alias iconSizeMenu : iconArea.iconSize
	
	background: Rectangle {
		color: button.down
			   ? MenuItemStyle.background.color.pressed
			   : (
					 button.hovered
					 ? MenuItemStyle.background.color.hovered
					 : MenuItemStyle.background.color.normal
					 )
		implicitHeight: MenuItemStyle.background.height
	}
	contentItem:Row{
		leftPadding: MenuItemStyle.leftPadding
		rightPadding: MenuItemStyle.rightPadding
		spacing:20
		Icon{
			id: iconArea
			visible: icon
			width: icon?iconSize:0
		}
		Text {
			color: button.enabled
				   ? MenuItemStyle.text.color.enabled
				   : MenuItemStyle.text.color.disabled
			
			elide: Text.ElideRight
			
			font {
				bold: true
				pointSize: MenuItemStyle.text.pointSize
			}
			
			text: button.text
			
			//leftPadding: MenuItemStyle.leftPadding
			//rightPadding: MenuItemStyle.rightPadding
			
			verticalAlignment: Text.AlignVCenter
			anchors.top: parent.top
			anchors.bottom : parent.bottom
		}
	}
	
	hoverEnabled: true
}
