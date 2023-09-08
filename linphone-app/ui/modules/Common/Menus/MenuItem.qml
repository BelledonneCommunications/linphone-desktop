import QtQuick 2.7
import QtQuick.Controls 2.3  as Controls	//2.3 for menu property (Qt 5.10)
import QtQuick.Layouts 1.3

import Common 1.0

import Common.Styles 1.0

// =============================================================================

// Using MenuItem.icon doesn't seem to work as of 07/2021
// Workaround : Implement own Icon

Controls.MenuItem {
	id: button
	property alias iconMenu : iconArea.icon
	property alias iconSizeMenu: iconArea.iconSize
	property alias iconOverwriteColorMenu: iconArea.overwriteColor
	property alias iconLayoutDirection : rowArea.layoutDirection
	property alias radius: backgroundArea.radius
	property var menuItemStyle : MenuItemStyle.normal
	onMenuItemStyleChanged: if(!menuItemStyle) menuItemStyle = MenuItemStyle.normal
	
	property alias textWeight : rowText.font.bold
	property int offsetTopMargin : 0
	property int offsetBottomMargin : 0
	property bool displaySelection: true
	property bool isTabBar: false
	
	height:visible?undefined:0
	
	Component.onCompleted: if(!isTabBar) menu.width = Math.max(menu.width, implicitWidth)
	
	background: Rectangle {
		id: backgroundArea
		color: button.down
			   ? menuItemStyle.background.color.pressed.color
			   : (
					 button.hovered
					 ? menuItemStyle.background.color.hovered.color
					 : menuItemStyle.background.color.normal.color
					 )
		implicitHeight: button.menuItemStyle.background.height
	}
	contentItem:RowLayout{
		id:rowArea		
		spacing: iconArea.icon? 10 : 0
		Item{
			Layout.fillHeight: true
			Layout.preferredWidth: iconArea.icon?height/rowText.lineCount:0 
			Layout.leftMargin:(iconLayoutDirection == Qt.LeftToRight ? menuItemStyle.leftMargin : 0)
			Layout.rightMargin:(iconLayoutDirection == Qt.LeftToRight ? 0 : menuItemStyle.rightMargin)
			Icon{
				id: iconArea
				visible: icon
				anchors.centerIn: parent
				iconSize: rowText.lineCount > 0 ? rowText.contentHeight/rowText.lineCount + 2 : 0
				overwriteColor: button.enabled
								? (button.down
								   ? menuItemStyle.text.color.pressed.color
								   : (
										 button.hovered
										 ? menuItemStyle.text.color.hovered.color
										 : menuItemStyle.text.color.normal.color
										 ))
								: menuItemStyle.text.color.disabled.color
			}
		}
		Text {
			id:rowText
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.leftMargin:(isTabBar || iconLayoutDirection == Qt.LeftToRight ? 0 : menuItemStyle.leftMargin) + (button.checkable ? CheckBoxTextStyle.size : 0)
			Layout.rightMargin:(!isTabBar && iconLayoutDirection == Qt.LeftToRight ? menuItemStyle.rightMargin : 0)
			color: button.enabled
				   ? (button.down
					  ? menuItemStyle.text.color.pressed.color
					  : (
							button.hovered
							? menuItemStyle.text.color.hovered.color
							: menuItemStyle.text.color.normal.color
							))
				   : menuItemStyle.text.color.disabled.color
			
			elide: Text.ElideRight
			
			font {
				weight: menuItemStyle.text.weight
				pointSize: menuItemStyle.text.pointSize
			}
			
			text: button.text
			horizontalAlignment: Text.AlignLeft
			verticalAlignment: Text.AlignVCenter
		}
	}
	indicator: Rectangle {
		visible: button.checkable
		border.color: button.down
					  ? CheckBoxTextStyle.color.pressed.color
					  : (
							button.hovered
							? CheckBoxTextStyle.color.hovered.color
							: (
								button.checked
								? CheckBoxTextStyle.color.selected.color
								: CheckBoxTextStyle.color.normal.color
							  )
							)
		
		implicitHeight: CheckBoxTextStyle.size
		implicitWidth: CheckBoxTextStyle.size
		
		radius: CheckBoxTextStyle.radius
		
		x: button.leftPadding
		y: parent.height / 2 - height / 2
		
		Rectangle {
			color: button.down
				   ? CheckBoxTextStyle.color.pressed.color
				   : (button.hovered
					  ? CheckBoxTextStyle.color.hovered.color
					  : (
							button.checked
							? CheckBoxTextStyle.color.selected.color
							: CheckBoxTextStyle.color.normal.color
							)
					  )
			
			height: parent.height - y * 2
			width: parent.width - x * 2
			
			radius: CheckBoxTextStyle.radius
			visible: button.checked
			
			x: 4 // Fixed, no needed to use style file.
			y: 4 // Same thing.
		}
	}
	
	hoverEnabled: true
	MouseArea{
		anchors.fill:parent
		visible: button.displaySelection
		propagateComposedEvents:true
		acceptedButtons: Qt.NoButton
		cursorShape: parent.hovered
					 ? Qt.PointingHandCursor
					 : Qt.ArrowCursor
	}
}
