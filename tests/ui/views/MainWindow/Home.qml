import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone 1.0

// ===================================================================

ColumnLayout {
    spacing: 0

    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.leftMargin: 50
        Layout.topMargin: 50
        spacing: 30

        // Invit friends.
        Column {
            spacing: 8

            Text {
                color: '#5A585B'
                font.bold: true
                font.pointSize: 11
                text: qsTr('invitContactQuestion')
            }

            LightButton {
                text: qsTr('invitContact')
            }
        }

        // Add contacts.
        Column {
            spacing: 8

            Text {
                color: '#5A585B'
                font.bold: true
                font.pointSize: 11
                text: qsTr('addContactQuestion')
            }

            LightButton {
                text: qsTr('addContact')
            }
        }
    }

    // Tooltip checkbox area.
    CheckBoxText {
        Layout.alignment: Qt.AlignBottom
        Layout.fillWidth: true
        Layout.leftMargin: 50
        Layout.preferredHeight: 70

        text: qsTr('displayTooltip')
    }
}
