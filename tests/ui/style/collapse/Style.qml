pragma Singleton
import QtQuick 2.7

QtObject {
    property var background: Rectangle {
        color: 'transparent'
    }

    property int animationDuration: 200
    property int iconSize: 32
    property string icon: 'collapse'
}
