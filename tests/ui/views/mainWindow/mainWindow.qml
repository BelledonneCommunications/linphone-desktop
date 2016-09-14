import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import 'qrc:/ui/components/collapse'
import 'qrc:/ui/components/contact'
import 'qrc:/ui/components/form'
import 'qrc:/ui/components/misc'

ApplicationWindow {
    function openWindow (name) {
        var component = Qt.createComponent('qrc:/ui/views/' + name + '.qml');
        if (component.status !== Component.Ready) {
            console.debug('Window not ready.')
            if(component.status === Component.Error) {
                console.debug('Error:' + component.errorString())
            }
        } else {
            component.createObject(mainWindow).show()
        }
    }

    id: mainWindow
    minimumHeight: 70
    minimumWidth: 780
    title: 'Linphone'
    visible: true

    header: ToolBar {
        background: Rectangle {
            color: '#EAEAEA'
        }
        height: 70

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 20

            // Collapse.
            Collapse {
                Layout.preferredWidth: 25
                Layout.fillHeight: parent.height
                onCollapsed: {
                    mainWindow.height = collapsed ? 500 : 70
                }
            }

            // User info.
            ShortContactDescription {
                Layout.fillHeight: parent.height
                Layout.preferredWidth: 200
                sipAddress: 'e.miller@sip-linphone.org'
                username: 'Edward Miller'
            }

            // User actions.
            ActionButton {
                onClicked: openWindow('manageAccounts')
            }

            ActionButton {
                onClicked: openWindow('newCall')
            }

            // Search.
            TextField {
                signal searchTextChanged (string text)

                background: Rectangle {
                    color: '#FFFFFF'
                    implicitHeight: 30
                }
                id: searchText
                Layout.fillWidth: true
                onTextChanged: searchTextChanged(text)
                placeholderText: qsTr('mainSearchBarPlaceholder')
            }

            // Start conference.
            ActionButton {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                icon: 'conference'
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Main menu.
        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            spacing: 0

            MenuEntry {
                Layout.preferredHeight: 50
                Layout.preferredWidth: parent.width
                entryName: qsTr('homeEntry')
            }

            Item { Layout.preferredHeight: 2 }

            MenuEntry {
                Layout.preferredHeight: 50
                Layout.preferredWidth: parent.width
                entryName: qsTr('contactsEntry')
            }

            // History.
            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width
            }

            // Logo.
            Rectangle {
                Layout.preferredWidth: 250
                Layout.preferredHeight: 70
                color: '#EAEAEA'
            }
        }

        // Main content.
        Loader {
            Layout.fillHeight: true
            Layout.fillWidth: true
            source: 'qrc:/ui/views/mainWindow/contacts.qml'
        }
    }
}
