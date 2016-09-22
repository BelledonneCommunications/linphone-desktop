import QtQuick 2.7
import QtGraphicalEffects 1.0

// ===================================================================

Item {
    property alias image: imageToFilter.source
    property string presence
    property string username

    // Image mask. (Circle)
    Rectangle {
        anchors.fill: parent
        color: '#8F8F8F'
        id: mask
        radius: 50
    }

    // Initials.
    Text {
        anchors.centerIn: parent
        color: '#FFFFFF'
        text: {
            var spaceIndex = username.indexOf(' ')
            var firstLetter = username.charAt(0)

            if (spaceIndex === -1) {
                return firstLetter
            }

            return firstLetter + username.charAt(spaceIndex + 1)
        }
    }

    Image {
        anchors.fill: parent
        id: imageToFilter
        fillMode: Image.PreserveAspectFit

        // Image must be invisible.
        // The only visible image is the OpacityMask!
        visible: false
    }

    // Avatar.
    OpacityMask {
        anchors.fill: imageToFilter
        maskSource: mask
        source: imageToFilter
    }

    // Presence.
    Image {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        fillMode: Image.PreserveAspectFit
        height: parent.height / 3
        id: presenceImage
        source: presence
            ? 'qrc:/imgs/led_' + presence + '.svg'
            : ''
        width: parent.width / 3
    }
}
