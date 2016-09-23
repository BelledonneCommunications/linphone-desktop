import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import 'qrc:/ui/style'

// ===================================================================
// Helper to build quickly dialogs.
// ===================================================================

Window {
    default property alias content: content.data // Required.
    property alias buttons: buttons.data // Optionnal.
    property alias descriptionText: description.text // Optionnal.
    property bool centeredButtons: false

    property bool _disableExitStatus

    signal exitStatus (int status)

    // Derived class must use this function instead of close.
    function exit (status) {
        if (!_disableExitStatus) {
            _disableExitStatus = true
            exitStatus(status)
            close()
        }
    }

    modality: Qt.WindowModal

    // Handle normal windows close.
    onClosing: !_disableExitStatus && exitStatus(0)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Description.
        DialogDescription {
            id: description

            Layout.fillWidth: true
        }

        // Content.
        Item {
            id: content

            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        // Buttons.
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: DialogStyle.buttonsAreaHeight

            Row {
                id: buttons

                anchors.left: (!centeredButtons && parent.left) || undefined
                anchors.centerIn: centeredButtons ? parent : undefined
                anchors.leftMargin: DialogStyle.leftMargin
                anchors.verticalCenter: (!centeredButtons && parent.verticalCenter) || undefined
                spacing: DialogStyle.buttonsSpacing
            }
        }
    }
}
