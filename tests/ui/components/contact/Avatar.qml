import QtQuick 2.7
import QtGraphicalEffects 1.0

// ===================================================================

Item {
    property string username
    property alias image: imageToFilter.source

    Rectangle {
        anchors.fill: parent
        color: '#8F8F8F'
        id: avatar
        radius: 20
    }

    Text {
        anchors.centerIn: parent
        color: '#FFFFFF'
        text: (function () {
            var spaceIndex = username.indexOf(' ')
            var firstLetter = username.charAt(0)

            if (spaceIndex === -1) {
                return firstLetter
            }

            return firstLetter + username.charAt(spaceIndex + 1)
        })()
    }

    Image {
        anchors.fill: parent
        id: imageToFilter
        fillMode: Image.PreserveAspectFit

        // Image must be invisible.
        // The only visible image is the OpacityMask!
        visible: false
    }

    OpacityMask {
        anchors.fill: imageToFilter
        source: imageToFilter
        maskSource: avatar
    }
}
