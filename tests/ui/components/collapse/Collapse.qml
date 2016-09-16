import QtQuick 2.7

import 'qrc:/ui/components/image'

// ===================================================================

Item {
    property bool enabled: false

    signal collapsed (bool collapsed)

    function updateCollapse () {
        enabled = !enabled
        collapsed(enabled)
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
        from: enabled ? 0 : 180
        id: rotate
        property: 'rotation'
        target: backgroundImage
        to: enabled ? 180 : 0
    }
}
