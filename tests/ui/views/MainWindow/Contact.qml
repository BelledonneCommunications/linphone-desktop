import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import Linphone 1.0

ColumnLayout  {
    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 102
        color: '#D1D1D1'

        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            height: 80
            spacing: 0
            width: parent.width

            Avatar {
                Layout.fillHeight: true
                Layout.preferredWidth: 80
                Layout.rightMargin: 30
                presence: 'connected' // TODO: Use C++.
                username: 'Cameron Andrews' // TODO: Use C++.
            }

            // TODO: Replace by text edit.
            // Component: EditableContactDescription.
            ContactDescription {
                Layout.fillHeight: true
                Layout.fillWidth: true
                username: 'Cameron Andrews' // TODO: Use C++.
            }

            ActionBar {
                iconSize: 32
                Layout.alignment: Qt.AlignBottom | Qt.AlignRight

                ActionButton {
                    icon: 'delete'
                    onClicked: console.log('clicked!!!')
                }

                ActionButton {
                    icon: 'contact'
                    onClicked: console.log('clicked!!!')
                }
            }
        }
    }

    Flickable {
        Layout.fillHeight: true
        Layout.fillWidth: true
        ScrollBar.vertical: ForceScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        contentHeight: content.height
        flickableDirection: Flickable.VerticalFlick

        ColumnLayout {
            anchors.left: parent.left
            anchors.margins: 20
            anchors.right: parent.right
            id: content

            ListForm {
                title: qsTr('sipAccounts')
            }

            ListForm {
                title: qsTr('address')
            }

            ListForm {
                title: qsTr('emails')
            }

            ListForm {
                title: qsTr('webSites')
            }
        }
    }
}
