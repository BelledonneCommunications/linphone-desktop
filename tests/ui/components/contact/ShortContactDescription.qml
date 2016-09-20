import QtQuick 2.7

// ===================================================================

Column {
    property alias sipAddress: sipAddress.text
    property alias username: username.text

    // Username.
    Text {
        clip: true
        color: '#5A585B'
        font.pointSize: 11
        font.bold: true
        height: parent.height / 2
        id: username
        verticalAlignment: Text.AlignBottom
        width: parent.width
    }

    // Sip address.
    Text {
        clip: true
        color: '#5A585B'
        height: parent.height / 2
        id: sipAddress
        verticalAlignment: Text.AlignTop
        width: parent.width
    }
}
