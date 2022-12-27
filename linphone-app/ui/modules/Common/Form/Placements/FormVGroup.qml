import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// =============================================================================

ColumnLayout {
	property alias label: label.text
	property alias labelFont: label.font
	
	default property var _content: null
	property int maxWidth: FormVGroupStyle.content.maxWidth
	
	// ---------------------------------------------------------------------------
	
	spacing: FormVGroupStyle.spacing
	width: parent.maxItemWidth
	
	// ---------------------------------------------------------------------------
	
	Text {
		id: label
		
		Layout.fillWidth: true
		
		color: FormVGroupStyle.legend.colorModel.color
		elide: Text.ElideRight
		font.pointSize: FormVGroupStyle.legend.pointSize
		verticalAlignment: Text.AlignVCenter
		
		TooltipArea {
			delay: 0
			text: parent.text
			visible: parent.truncated
		}
	}
	
	// ---------------------------------------------------------------------------
	
	Item {
		readonly property int currentHeight: _content ? _content.height : 0
		
		Layout.fillWidth: true
		Layout.preferredHeight: currentHeight
		
		Loader {
			active: !!_content
			anchors.fill: parent
			
			sourceComponent: Item {
				id: content
				
				data: [ _content ]
				width: parent.width
				
				Component.onCompleted: _content.width = Qt.binding(function () {
					var contentWidth = content.width
					var wishedWidth = parent.parent.parent.maxWidth
					return contentWidth > wishedWidth ? wishedWidth : contentWidth
				})
			}
		}
	}
}
