pragma Singleton
import QtQuick 2.7

import 'qrc:/ui/style/global'

QtObject {
    property string color: Colors.c
    property string pressedColor: Colors.b

    property Rectangle background: Rectangle {
        color: Colors.d
    }

    property Rectangle contentItem: Rectangle {
        implicitHeight: 100
        implicitWidth: 8
        radius: 10
    }
}
