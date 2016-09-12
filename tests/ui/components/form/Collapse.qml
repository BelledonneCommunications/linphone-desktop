import QtQuick 2.7
import QtQuick.Controls 2.0

// ===================================================================

Item {
    property bool enabled: false
    property alias image: backgroundImage.source

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
