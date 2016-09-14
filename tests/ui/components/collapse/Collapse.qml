import QtQuick 2.7

// ===================================================================

Item {
    property bool enabled: false

    signal collapsed (bool collapsed)

    function updateCollapse () {
        enabled = !enabled
        collapsed(enabled)
        rotate.start()
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        id: backgroundImage
        source: 'qrc:/imgs/collapse.svg'

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
