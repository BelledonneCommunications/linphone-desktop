import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import 'qrc:/ui/components/scrollBar'

ListView {
    ScrollBar.vertical: ForceScrollBar { }
    boundsBehavior: Flickable.StopAtBounds
    clip: true
    highlightRangeMode: ListView.ApplyRange
    spacing: 10

    model: ListModel {
        ListElement { $timestamp: 1465389121; $type: 'message'; $message: 'This is it: fefe efzzzzzzzzzz aaaaaaaaa erfeezffeefzfzefzefzezfefez wfef efef  e efeffefe fee efefefeefef fefefefefe eff fefefe fefeffww.linphone.org' }
        ListElement { $type: 'message'; $message: 'Perfect!' }
    }

    delegate: Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.right: parent.right
        anchors.rightMargin: 18

        // Unable to use `height` property.
        // The height is given by message height.
        implicitHeight: layout.height
        width: parent.width

        RowLayout {
            id: layout

            // The height is computed with the message height.
            // Unable to use `height` and `implicitHeight` property.
            width: parent.width

            Rectangle {
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: 15
                Layout.preferredWidth: 42
                color: 'blue'
            }

            Loader {
                Layout.fillWidth: true
                id: loader
                source: 'qrc:/ui/components/chat/IncomingMessage.qml'
            }
        }
    }
}
