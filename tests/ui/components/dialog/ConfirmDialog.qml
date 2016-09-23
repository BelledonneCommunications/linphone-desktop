import QtQuick 2.7

import 'qrc:/ui/components/form'
import 'qrc:/ui/style'

// ===================================================================
// A simple dialog with OK/Cancel buttons.
// ===================================================================

DialogPlus {
    id: dialog

    buttons: [
        DarkButton {
            text: qsTr('cancel')

            onClicked: exit(0)
        },
        DarkButton {
            text: qsTr('confirm')

            onClicked: exit(1)
        }
    ]
    centeredButtons: true
    maximumHeight: DialogStyle.confirm.height
    maximumWidth: DialogStyle.confirm.width
    minimumHeight: DialogStyle.confirm.height
    minimumWidth: DialogStyle.confirm.width
}
