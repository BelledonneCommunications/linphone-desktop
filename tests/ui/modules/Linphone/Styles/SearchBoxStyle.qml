pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
    property string shadowColor: Colors.f

    property Rectangle searchFieldBackground: Rectangle {
        implicitHeight: 30
    }
}
