import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone 1.0

// ===================================================================

Item {
    property alias actions: actionBar.data
    property alias image: avatar.image
    property alias presence: avatar.presence
    property alias sipAddress: contactDescription.sipAddress
    property string username

    id: contact
    height: 50

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 14

        Avatar {
            Layout.preferredHeight: 32
            Layout.preferredWidth: 32
            id: avatar
            username: contact.username
        }

        ContactDescription {
            Layout.fillHeight: true
            Layout.fillWidth: true
            id: contactDescription
            username: contact.username
        }

        ActionBar {
            Layout.preferredHeight: 32
            id: actionBar
        }
    }
}
