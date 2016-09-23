import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import 'qrc:/ui/components/collapse'
import 'qrc:/ui/components/contact'
import 'qrc:/ui/components/form'
import 'qrc:/ui/components/misc'
import 'qrc:/ui/components/searchBox'
import 'qrc:/ui/components/timeline'

import 'qrc:/ui/scripts/utils.js' as Utils

ApplicationWindow {
    id: mainWindow
    maximumHeight: 70
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
                id: collapse

                onCollapsed: mainWindowStates.state = collapsed
                    ? 'collapsed'
                    : ''
            }

            // User info.
            ContactDescription {
                Layout.fillHeight: parent.height
                Layout.preferredWidth: 200
                sipAddress: 'e.miller@sip-linphone.org'
                username: 'Edward Miller'
            }

            // User actions.
            ActionButton {
                Layout.preferredWidth: 16
                onClicked: Utils.openWindow('manageAccounts', mainWindow)
            }

            ActionButton {
                Layout.preferredWidth: 16
                onClicked: Utils.openWindow('newCall', mainWindow)
            }

            // Search.
            SearchBox {
                Layout.fillWidth: true
                maxMenuHeight: 300 // See Hick's law for good choice.
                placeholderText: qsTr('mainSearchBarPlaceholder')

                onMenuClosed: content.enabled = true

                onMenuOpened: {
                    if (!collapse.isCollapsed) {
                        collapse.collapse()
                    }
                    content.enabled = false
                }
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
        id: content
        spacing: 0

        // Main menu.
        ColumnLayout {
            Layout.fillHeight: true
            Layout.maximumWidth: 250
            Layout.preferredWidth: 250
            spacing: 0

            MenuEntry {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                entryName: qsTr('homeEntry')
            }

            Item { Layout.preferredHeight: 2 }

            MenuEntry {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                entryName: qsTr('contactsEntry')
            }

            // History.
            Timeline {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            // Logo.
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: '#EAEAEA'
            }
        }

        // Main content.
        Loader {
            Layout.fillHeight: true
            Layout.fillWidth: true
            source: 'qrc:/ui/views/mainWindow/conversation.qml'
        }
    }

    StateGroup {
        id: mainWindowStates

        states: State {
            name: 'collapsed'

            PropertyChanges {
                height: 480
                maximumHeight: 99999
                maximumWidth: 99999
                minimumHeight: 480
                target: mainWindow
            }
        }
    }
}
