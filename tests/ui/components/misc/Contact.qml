import QtQuick 2.7
import QtQuick.Layouts 1.3

Item {
    property alias sipAddress: sipAddressText.text
    property alias username: usernameText.text
    property string avatar: 'qrc:/imgs/avatar.svg' // Default.

    id: contact
    height: 50

    RowLayout {
        anchors.fill: parent

        // Avatar.
        Image {
            Layout.fillHeight: parent.height
            Layout.margins: 5
            Layout.preferredWidth: 50
            fillMode: Image.PreserveAspectFit
            id: avatarImage
            source: contact.avatar
        }

        // Sip address & username.
        Column {
            Layout.fillHeight: parent.height
            Layout.fillWidth: true

            // Sip address.
            Text {
                clip: true
                color: '#5A585B'
                font.weight: Font.DemiBold
                height: parent.height / 2
                id: sipAddressText
                verticalAlignment: Text.AlignBottom
                width: parent.width
            }

            // Username.
            Text {
                clip: true
                color: '#5A585B'
                height: parent.height / 2
                id: usernameText
                verticalAlignment: Text.AlignTop
                width: parent.width
            }
        }

        // Actions.
        Row {
            Layout.fillHeight: parent.height
            Layout.preferredWidth: 90
            Layout.margins: 10

            // Call.
            Image {
                fillMode: Image.PreserveAspectFit
                height: parent.height
                source: 'qrc:/imgs/phone.svg'
                width: parent.width / 2
            }

            // Camera.
            Image {
                fillMode: Image.PreserveAspectFit
                height: parent.height
                source: 'qrc:/imgs/camera.svg'
                width: parent.width / 2
            }
        }
    }
}
