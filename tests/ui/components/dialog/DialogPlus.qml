import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import 'qrc:/ui/style/components'

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
    // Destroy the component and send signal to caller.
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
        Row {
            id: buttons

            Layout.alignment: (centeredButtons && Qt.AlignHCenter) || Qt.AlignLeft
            Layout.bottomMargin: DialogStyle.buttons.bottomMargin
            Layout.leftMargin: (!centeredButtons && DialogStyle.leftMargin) || undefined
            Layout.topMargin: DialogStyle.buttons.topMargin
            spacing: DialogStyle.buttons.spacing
        }
    }
}
