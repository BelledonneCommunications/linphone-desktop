import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import 'qrc:/ui/components/dialog'
import 'qrc:/ui/components/form'

Window {
    default property alias contents: content.data

    // Optionnal description text.
    property alias descriptionText: description.text

    // Required buttons.
    property alias buttons: buttons.data

    id: window
    modality: Qt.WindowModal

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Description.
        DialogDescription {
            Layout.alignment : Qt.AlignTop
            Layout.fillWidth: true
            id: description
        }

        // Content.
        Item {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            id: content
        }

        // Buttons.
        Item {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            height: 100

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 50
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 30
                id: buttons
                spacing: 20
            }
        }
    }
}
