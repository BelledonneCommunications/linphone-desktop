pragma Singleton
import QtQuick 2.7

QtObject {
    property int animationDuration: 200
    property int iconSize: 32
    property string icon: 'collapse'

    property Rectangle background: Rectangle {
        color: 'transparent'
    }
}
