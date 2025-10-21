import QtQuick
import QtQuick.Layouts
import QtQml.Models
import QtQuick.Controls.Basic as Control

import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

// =============================================================================
GridLayout {
	id: mainItem
	property ChatMessageContentProxy proxyModel
	property bool isHoveringFile: false
	property int itemCount: delModel.count
	property int itemWidth: Utils.getSizeWithScreenRatio(95)
	// cellWidth: 
	// cellHeight: Utils.getSizeWithScreenRatio(105)
	property real maxWidth: Utils.getSizeWithScreenRatio(3 * 105)
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