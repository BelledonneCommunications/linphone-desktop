import QtQuick 2.7 as Quick

import Common 1.0
import Common.Styles 1.0

Quick.MouseArea {
	property bool interactive: true
    cursorShape: containsMouse && interactive
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor
    hoverEnabled: interactive
}
