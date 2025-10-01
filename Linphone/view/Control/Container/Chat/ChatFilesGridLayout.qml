import QtQuick
import QtQuick.Layouts
import QtQml.Models
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp

// =============================================================================
GridLayout {
	id: mainItem
	property ChatMessageContentProxy proxyModel
	property bool isHoveringFile: false
	property int itemCount: delModel.count
	property int itemWidth: Math.round(95 * DefaultStyle.dp)
	// cellWidth: 
	// cellHeight: Math.round(105 * DefaultStyle.dp)
	property real maxWidth: 3 * 105 * DefaultStyle.dp
	columns: optimalColumns
	

	property int optimalColumns: {
		let maxCols = Math.floor(maxWidth / itemWidth);
		let bestCols = 1;
		let minRows = Number.MAX_VALUE;
		let minEmptySlots = Number.MAX_VALUE;

		for (let cols = maxCols; cols >= 1; cols--) {
			let rows = Math.ceil(itemCount / cols);
			let emptySlots = cols * rows - itemCount;

			if (
				rows < minRows || 
				(rows === minRows && emptySlots < minEmptySlots)
			) {
				bestCols = cols;
				minRows = rows;
				minEmptySlots = emptySlots;
			}
		}

		return bestCols;
	}

	Repeater {
		id: delModel
		model: mainItem.proxyModel
		delegate: FileView {
			id: avatarCell
			contentGui: modelData
			visible: modelData
			height: mainItem.itemWidth
			width: mainItem.itemWidth
			// onIsHoveringChanged: mainItem.isHoveringFile = isHovering
		}
	}
}