import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Controls.TabButton {
	id: button
	
	// ---------------------------------------------------------------------------
	
	property int iconSize: TabButtonStyle.icon.size
	property string iconName
	property alias textFont: textItem.font
	
	readonly property bool isSelected: parent.parent.currentItem === button
	
	property bool displaySelector: false
	property bool stretchContent: true
	property QtObject style: TabButtonStyle.menu
	// ---------------------------------------------------------------------------
	
	function _getBackgroundColor () {
		if(!button.style)
			return ''
		if (isSelected) {
			return button.style.backgroundColor.selected.color
		}
		
		return button.enabled
				? (
					  button.down
					  ? button.style.backgroundColor.pressed.color
					  : (
							button.hovered
							? button.style.backgroundColor.hovered.color
							: button.style.backgroundColor.normal.color
							)
					  )
				: button.style.backgroundColor.disabled.color
	}
	
	function _getTextColor () {
		if(!button.style)
			return ''
		if (isSelected) {
			return button.style.text.color.selected.color
		}
		
		return button.enabled
				? (
					  button.down
					  ? button.style.text.color.pressed.color
					  : (
							button.hovered
							? button.style.text.color.hovered.color
							: button.style.text.color.normal.color
							)
					  )
				: button.style.text.color.disabled.color
	}
	
	// ---------------------------------------------------------------------------
	
	background: Rectangle {
		color: _getBackgroundColor()
		implicitHeight: TabButtonStyle.text.height
		Rectangle{
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			height: 2
			visible: button.displaySelector && button.isSelected
			color: button.style ? button.style.selector.color : ''
		}
	}
	
	contentItem: RowLayout {
		height: button.height
		width: button.width
		spacing: TabButtonStyle.spacing
		Item{
			Layout.fillWidth: visible
			Layout.fillHeight: true
			visible: !button.stretchContent
		}
		Icon {
			id: icon
			
			Layout.fillHeight: true
			Layout.leftMargin: visible ? TabButtonStyle.text.leftPadding : 0
			overwriteColor: textItem.color
			
			icon: button.iconName
			iconSize: visible ? button.iconSize : 0
			visible: button.iconName
		}
		
		Text {
			id: textItem
			Layout.fillWidth: true
			Layout.fillHeight: true
			
			color: _getTextColor()
			
			font {
				bold: true
				pointSize: TabButtonStyle.text.pointSize
			}
			
			elide: Text.ElideRight
			
			height: parent.height
			
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			
			rightPadding: TabButtonStyle.text.rightPadding
			text: button.text
			textFormat: Text.RichText
		}
		Item{
			Layout.fillWidth: visible
			Layout.fillHeight: true
			visible: !button.stretchContent
		}
	}
	
	hoverEnabled: true
}
