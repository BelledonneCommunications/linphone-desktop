import QtQuick 2.7

import 'qrc:/ui/components/form'

// ===================================================================

DialogPlus {
    buttons: [
        DarkButton {
            onClicked: exit(0)
            text: qsTr('cancel')
        },
        DarkButton {
            onClicked: exit(1)
            text: qsTr('confirm')
        }
    ]
    centeredButtons: true
    id: dialog
    maximumWidth: 370
    maximumHeight: 150
    minimumWidth: 370
    minimumHeight: 150
}
