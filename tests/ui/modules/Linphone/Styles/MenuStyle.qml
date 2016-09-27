pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
    property int spacing: 2

    property QtObject entry: QtObject {
        property int fontSize: 13
        property int iconSize: 24
        property int leftMargin: 20
        property int rightMargin: 20
        property int selectionIconSize: 12
        property int spacing: 18

        property string selectionIcon: 'right_arrow'
        property string textColor: Colors.k

        property QtObject color: QtObject {
            property string normal: Colors.g
            property string hovered: Colors.h
            property string pressed: Colors.i
            property string selected: Colors.j
        }
    }
}
