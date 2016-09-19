import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import 'qrc:/ui/components/contact'
import 'qrc:/ui/components/scrollBar'

ColumnLayout {
    Row {
        Layout.preferredHeight: 35
        spacing: 30

        Image {
            fillMode: Image.PreserveAspectFit
            height: parent.height
            width: 20
        }

        Text {
            color: '#5A585B'
            font.pointSize: 13
            height: parent.height
            text: qsTr('timelineTitle')
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        color: '#DEDEDE'
        Layout.fillWidth: true
        Layout.preferredHeight: 1
    }

    ListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        ScrollBar.vertical: ForceScrollBar { }
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        highlightRangeMode: ListView.ApplyRange
        spacing: 0

        // Replace by C++ class.
        model: ListModel {
            ListElement {
                $presence: 'connected'
                $sipAddress: 'jim.williams.zzzz.yyyy.kkkk.sip.linphone.org'
                $username: 'Toto'
            }
            ListElement {
                $presence: 'connected'
                $sipAddress: 'toto.lala.sip.linphone.org'
                $username: 'Toto'
            }
            ListElement {
                $presence: 'disconnected'
                $sipAddress: 'machin.truc.sip.linphone.org'
                $username: 'Toto'
            }
            ListElement {
                $presence: 'absent'
                $sipAddress: 'hey.listen.sip.linphone.org'
                $username: 'Toto'
            }
            ListElement {
                $presence: 'do_not_disturb'
                $sipAddress: 'valentin.cognito.sip.linphone.org'
                $username: 'Toto'
            }
            ListElement {
                $presence: 'do_not_disturb'
                $sipAddress: 'charles.henri.sip.linphone.org'
                $username: 'Toto'
            }
            ListElement {
                $presence: 'disconnected'
                $sipAddress: 'yesyes.nono.sip.linphone.org'
                $username: 'Toto'
            }
            ListElement {
                $presence: 'connected'
                $sipAddress: 'nsa.sip.linphone.org'
                $username: 'Toto'
            }
        }

        delegate: Contact {
            presence: $presence
            sipAddress: $sipAddress
            username: $username
            width: parent.width
        }
    }
}
