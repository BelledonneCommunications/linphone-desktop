import QtQuick 2.7

import 'qrc:/ui/components/image'

// ===================================================================

Item {
    property bool isCollapsed: false

    signal collapsed (bool collapsed)

    function updateCollapse () {
        isCollapsed = !isCollapsed
        collapsed(isCollapsed)
        rotate.start()
    }

    Icon {
        anchors.fill: parent
        id: backgroundImage
        icon: 'collapse'

        MouseArea {
            anchors.fill: parent
            onClicked: updateCollapse()
        }
    }

    RotationAnimation {
        direction: RotationAnimation.Clockwise
        duration: 200
        from: isCollapsed ? 0 : 180
        id: rotate
        property: 'rotation'
        target: backgroundImage
        to: isCollapsed ? 180 : 0
    }
}
