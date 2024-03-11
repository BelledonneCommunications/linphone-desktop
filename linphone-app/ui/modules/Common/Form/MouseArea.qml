import QtQuick 2.7 as Quick

import Common 1.0
import Common.Styles 1.0

Quick.MouseArea {
	property int hoveredCursor: Qt.PointingHandCursor
	cursorShape: containsMouse
				 ? hoveredCursor
				 : Qt.ArrowCursor
	hoverEnabled: true
}
