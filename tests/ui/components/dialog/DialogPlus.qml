import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

// ===================================================================
// Helper to build quickly dialogs.
// ===================================================================

Window {
    default property alias content: content.data // Required.
    property alias buttons: buttons.data // Required.
    property alias descriptionText: description.text // Optionnal.
    property bool centeredButtons // Optionnal.

    property bool disableExitStatus // Internal property.

    signal exitStatus (int status)

    modality: Qt.WindowModal

    // Handle normal windows close.
    onClosing: !disableExitStatus && exitStatus(0)

    // Derived class must use this function instead of close.
    function exit (status) {
        if (!disableExitStatus) {
            disableExitStatus = true
            exitStatus(status)
            close()
        }
    }

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
            height: 60

            Row {
                anchors.left: (!centeredButtons && parent.left) || undefined
                anchors.centerIn: centeredButtons ? parent : undefined
                anchors.leftMargin: 50
                height: 30
                id: buttons
                spacing: 20
            }
        }
    }
}
