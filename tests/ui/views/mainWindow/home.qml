import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import 'qrc:/ui/components/form'

// ===================================================================

ColumnLayout {
    spacing: 0

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Item {
            anchors.fill: parent
            anchors.leftMargin: 50
            anchors.topMargin: 50

            Column {
                spacing: 30

                // Invit friends.
                Column {
                    spacing: 8

                    Text {
                        text: qsTr('invitContactQuestion')
                        font.weight: Font.DemiBold
                        color: '#5A585B'
                        font.pointSize: 11
                    }

                    DialogButton {
                        backgroundColor: '#D1D1D1'
                        text: qsTr('invitContact')
                        textColor: '#5A585B'
                    }
                }

                // Add contacts.
                Column {
                    spacing: 8

                    Text {
                        text: qsTr('addContactQuestion')
                        font.weight: Font.DemiBold
                        color: '#5A585B'
                        font.pointSize: 11
                    }

                    DialogButton {
                        backgroundColor: '#D1D1D1'
                        text: qsTr('addContact')
                        textColor: '#5A585B'
                    }
                }
            }
        }
    }

    // Tooltip checkbox area.
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 70

        DialogCheckBox {
            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr('displayTooltip')
        }
    }
}
