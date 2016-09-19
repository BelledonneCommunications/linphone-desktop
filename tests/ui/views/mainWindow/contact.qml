import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import 'qrc:/ui/components/form'
import 'qrc:/ui/components/scrollBar'

ColumnLayout  {
    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 102
        color: '#D1D1D1'
    }

    Flickable {
        Layout.fillHeight: true
        Layout.fillWidth: true
        ScrollBar.vertical: ForceScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        contentHeight: content.height
        flickableDirection: Flickable.VerticalFlick

        ColumnLayout {
            anchors.left: parent.left
            anchors.margins: 20
            anchors.right: parent.right
            id: content

            ListForm {
                title: qsTr('sipAccounts')
            }

            ListForm {
                title: qsTr('address')
            }

            ListForm {
                title: qsTr('emails')
            }

            ListForm {
                title: qsTr('webSites')
            }
        }
    }
}
