import QtQuick 2.7
import QtQuick.Controls 2.2

import Common 1.0

import 'ListItemSelector.js' as Logic

// =============================================================================

ScrollableListViewField {
	property alias currentIndex: view.currentIndex
	property alias iconRole: view.iconRole
	property alias model: view.model
	property alias textRole: view.textRole
	property alias contentHeight: view.contentHeight
	
	signal activated (int index)
	
	radius: 0
	ScrollableListView {
		id: view
		
		// -------------------------------------------------------------------------
		
		property string textRole
		property var iconRole
		onContentHeightChanged: parent.implicitHeight = contentHeight
		
		// -------------------------------------------------------------------------
		
		anchors.fill: parent
		currentIndex: -1
		delegate: CommonItemDelegate {
			id: item
			
			container: view
			flattenedModel: view.textRole.length &&
							(typeof modelData !== 'undefined' ? modelData : model)
			itemIcon: Logic.getItemIcon(item)
			width: view.width
			onClicked: {activated(index)}
		}
	}
}
