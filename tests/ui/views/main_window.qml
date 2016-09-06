import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import 'qrc:/ui/components/Form'

ApplicationWindow {
    header: ToolBar {
        background: Rectangle {
            color: '#EAEAEA'
        }
        height: 70

        RowLayout {
            anchors.fill: parent
            anchors.rightMargin: 10

            // Collapse.
            Collapse {
                image: '/imgs/collapse.svg'
                onCollapsed: {
                    mainWindow.height = collapsed ? 480 : 70
                }
            }

            // User info.
            // TODO

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
                image: '/imgs/start_conference.svg'
            }
        }
    }
    id: mainWindow
    minimumHeight: 70
    minimumWidth: 640
    visible: true
}
