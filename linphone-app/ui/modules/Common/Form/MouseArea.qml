import QtQuick 2.7 as Quick

import Common 1.0
import Common.Styles 1.0

Quick.MouseArea {
    cursorShape: containsMouse
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor
    hoverEnabled: true
}
