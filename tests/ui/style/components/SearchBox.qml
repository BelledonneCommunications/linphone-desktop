pragma Singleton
import QtQuick 2.7

import 'qrc:/ui/style/global'

QtObject {
    property string shadowColor: Colors.a

    property Rectangle searchFieldBackground: Rectangle {
        implicitHeight: 30
    }
}
