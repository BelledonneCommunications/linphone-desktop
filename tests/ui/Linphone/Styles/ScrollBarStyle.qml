pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
    property string color: Constants.colors.c
    property string pressedColor: Constants.colors.b

    property Rectangle background: Rectangle {
        color: Constants.colors.d
    }

    property Rectangle contentItem: Rectangle {
        implicitHeight: 100
        implicitWidth: 8
        radius: 10
    }
}
