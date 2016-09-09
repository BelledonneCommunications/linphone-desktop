import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

Window {
    default property alias contents: content.data

    // Optionnal description text.
    property alias descriptionText: description.text

    // Required buttons.
    property alias buttons: buttons.data

    modality: Qt.WindowModal

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Description.
        DialogDescription {
            Layout.fillWidth: true
            id: description
        }

        // Content.
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            id: content
        }

        // Buttons.
        Item {
            Layout.fillWidth: true
            height: 100

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 50
                anchors.verticalCenter: parent.verticalCenter
                height: 30
                id: buttons
                spacing: 20
            }
        }
    }
}
