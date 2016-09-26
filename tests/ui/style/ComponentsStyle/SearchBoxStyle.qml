pragma Singleton
import QtQuick 2.7

import AppStyle 1.0

QtObject {
    property string shadowColor: Colors.a

    property Rectangle searchFieldBackground: Rectangle {
        implicitHeight: 30
    }
}
