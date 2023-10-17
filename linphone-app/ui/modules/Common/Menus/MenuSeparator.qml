import QtQuick 2.7
import QtQuick.Controls 2.3 as Controls

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Controls.MenuSeparator {
	padding: 0
	topPadding: MenuSeparatorStyle.topPadding
	bottomPadding: MenuSeparatorStyle.bottomPadding
	contentItem: Rectangle {
		implicitHeight: MenuSeparatorStyle.height
		color: MenuSeparatorStyle.colorModel.color
	}
}
