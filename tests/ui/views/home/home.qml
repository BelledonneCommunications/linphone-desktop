import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import 'qrc:/ui/components/form'
import 'qrc:/ui/components/misc'

ApplicationWindow {
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
                image: 'qrc:/imgs/collapse.svg'
                onCollapsed: {
                    mainWindow.height = collapsed ? 480 : 70
                }
            }

            // User info.
            Column {
                Layout.preferredWidth: 200
                Layout.fillHeight: parent.height

                // Username.
                Text {
                    clip: true
                    color: '#5A585B'
                    font.weight: Font.DemiBold
                    height: parent.height / 2
                    font.pointSize: 11
                    text: 'Edward Miller'
                    verticalAlignment: Text.AlignBottom
                    width: parent.width
                }

                // Sip address.
                Text {
                    clip: true
                    color: '#5A585B'
                    height: parent.height / 2
                    text: 'e.miller@sip-linphone.org'
                    verticalAlignment: Text.AlignTop
                    width: parent.width
                }
            }

            // User actions.
            ToolBarButton {
                onClicked: {
                    var component = Qt.createComponent('qrc:/ui/views/newCall.qml');
                    if (component.status !== Component.Ready) {
                        console.debug('Window not ready.')
                        if(component.status === Component.Error) {
                            console.debug('Error:' + component.errorString())
                        }
                    } else {
                        component.createObject(mainWindow).show()
                    }
                }
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
            ToolBarButton {
                Layout.fillHeight: parent.height
                Layout.preferredWidth: 32
                image: 'qrc:/imgs/start_conference.svg'
            }
        }
    }
    id: mainWindow
    minimumHeight: 70
    minimumWidth: 640
    title: 'Linphone'
    visible: true

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

            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width
            }

            Rectangle {
                Layout.preferredWidth: 250
                Layout.preferredHeight: 70
                color: '#EAEAEA'
            }
        }

        // Main content.
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: 'blue'
        }
    }
}
