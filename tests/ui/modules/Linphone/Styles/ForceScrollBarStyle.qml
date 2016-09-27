pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
    property Rectangle background: Rectangle {
        color: Constants.colors.a
    }

    property Rectangle contentItem: Rectangle {
        implicitHeight: 100
        implicitWidth: 8
        radius: 10
    }

    property QtObject color: QtObject {
        property string hovered: Constants.colors.h
        property string normal: Constants.colors.c
        property string pressed: Constants.colors.b
    }
}
