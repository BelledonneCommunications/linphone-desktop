import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "qrc:/ui/components/SearchBar"

ApplicationWindow {
    id: mainWindow
    visible: true

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
        }
    }

    footer: TabBar {

    }

    SearchBar {}
}
