import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

import 'ComboBox.js' as Logic

// =============================================================================

Controls.ComboBox {
	id: comboBox
	
	// ---------------------------------------------------------------------------
	
	property var iconRole
	property bool haveBorder: true
	property bool haveMargin: true
	property color backgroundColor: ComboBoxStyle.background.color.normal
	property color foregroundColor: ComboBoxStyle.contentItem.text.color
	
	property var rootItem 
	property int yPopup: rootItem ? -mapToItem(rootItem,x,y).y : height + 1
	property int maxPopupHeight : rootItem ? rootItem.height : 400
	
	property int selectionWidth: width
	
	clip: true
	// ---------------------------------------------------------------------------
	
	background: Rectangle {
		border {
			color: ComboBoxStyle.background.border.color
			width: comboBox.haveBorder ? ComboBoxStyle.background.border.width : 0
		}
		
		color: comboBox.enabled
			   ? comboBox.backgroundColor
			   : ComboBoxStyle.background.color.readOnly
		
		radius: ComboBoxStyle.background.radius
		
		implicitHeight: ComboBoxStyle.background.height
		implicitWidth: ComboBoxStyle.background.width
	}
	
	// ---------------------------------------------------------------------------
	
	contentItem: Item {
		height: comboBox.height
		width: comboBox.selectionWidth
		clip: true
		RowLayout {
			anchors {
				fill: parent
				leftMargin: comboBox.haveMargin ? ComboBoxStyle.contentItem.leftMargin : 0
			}
			
			spacing: ComboBoxStyle.contentItem.spacing
			
			Icon {
				icon: Logic.getSelectedEntryIcon()
				iconSize: ComboBoxStyle.contentItem.iconSize
				
				visible: icon.length > 0
			}
			
			Text {
				Layout.fillWidth: true
				
				color: comboBox.foregroundColor
				elide: Text.ElideRight
				
				font.pointSize: ComboBoxStyle.contentItem.text.pointSize
				rightPadding: comboBox.indicator.width + comboBox.spacing
				
				text: Logic.getSelectedEntryText()
			}
		}
	}
	
	// ---------------------------------------------------------------------------
	
	indicator: Icon {
		icon: ComboBoxStyle.indicator.dropDown.icon
		iconSize: ComboBoxStyle.indicator.dropDown.iconSize
		overwriteColor: ComboBoxStyle.indicator.dropDown.color
		
		x: comboBox.width - width - comboBox.rightPadding
		y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
	}
	
	// ---------------------------------------------------------------------------
	popup: Controls.Popup{
		y: comboBox.yPopup
		width: comboBox.selectionWidth
		implicitHeight: contentItem.contentHeight
		topPadding: 0
		bottomPadding: 0
		leftPadding: 0
		rightPadding: 0
		contentItem: ListItemSelector{
			model: comboBox.popup.visible ? comboBox.model : null
			currentIndex: comboBox.highlightedIndex
			textRole: comboBox.textRole
			onActivated: {comboBox.activated(index);comboBox.currentIndex = index;comboBox.popup.close()}
		}
	}
}
