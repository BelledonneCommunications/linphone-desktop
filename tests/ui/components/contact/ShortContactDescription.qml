import QtQuick 2.7

// ===================================================================

Column {
    property string sipAddress
    property string username

    // Username.
    Text {
        clip: true
        color: '#5A585B'
        font.pointSize: 11
        font.weight: Font.DemiBold
        height: parent.height / 2
        text: username
        verticalAlignment: Text.AlignBottom
        width: parent.width
    }

    // Sip address.
    Text {
        clip: true
        color: '#5A585B'
        height: parent.height / 2
        text: sipAddress
        verticalAlignment: Text.AlignTop
        width: parent.width
    }
}
