import QtQuick 2.7

Rectangle {
    property string username
    property string image

    color: '#8F8F8F'
    radius: 20

    Text {
        anchors.centerIn: parent
        text: (function () {
            var spaceIndex = username.indexOf(' ')
            var firstLetter = username.charAt(0)

            if (spaceIndex === -1) {
                return firstLetter
            }

            return firstLetter + username.charAt(spaceIndex + 1)
        })()
        color: '#FFFFFF'
    }
}
