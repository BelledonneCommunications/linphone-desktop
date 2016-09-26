pragma Singleton
import QtQuick 2.7

import AppStyle 1.0

QtObject {
    property QtObject shadow: QtObject {
        property double radius: 8.0
        property int horizontalOffset: 0
        property int samples: 15
        property int verticalOffset: 2
        property string color: Colors.a
    }
}
