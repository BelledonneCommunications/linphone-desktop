pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
    property string shadowColor: Constants.colors.f

    property Rectangle searchFieldBackground: Rectangle {
        implicitHeight: 30
    }
}
