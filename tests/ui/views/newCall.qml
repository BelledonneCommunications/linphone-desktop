import QtQuick 2.7
import QtQuick.Controls 2.0

import 'qrc:/ui/components/dialog'
import 'qrc:/ui/components/form'
import 'qrc:/ui/components/select'

DialogPlus {
    centeredButtons: true
    minimumHeight: 300
    minimumWidth: 420
    title: qsTr('newCallTitle')

    buttons: DialogButton {
        text: qsTr('cancel')
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 25
        anchors.rightMargin: 25

        SelectContact {
            anchors.fill: parent
        }
    }
}
