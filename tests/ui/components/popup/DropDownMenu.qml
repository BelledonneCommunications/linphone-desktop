import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0

import 'qrc:/ui/components/contact'
import 'qrc:/ui/components/form'
import 'qrc:/ui/components/scrollBar'
import 'qrc:/ui/style'

Rectangle {
    readonly property int entryHeight: 50

    property int maxMenuHeight

    implicitHeight: {
        var height = model.count * entryHeight
        return height > maxMenuHeight ? maxMenuHeight : height
    }
    visible: false

    function show () {
        visible = true
    }

    function hide () {
        visible = false
    }

    Rectangle {
        anchors.fill: parent
        id: listContainer

        ListView {
            ScrollBar.vertical: ForceScrollBar { }
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            highlightRangeMode: ListView.ApplyRange
            id: list
            spacing: 0
            height: console.log(model.count) || count

            // TODO: Remove, use C++ model instead.
            model: ListModel {
                id: model

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

                actions: [
                    ActionButton {
                        icon: 'call'
                        onClicked: console.log('clicked')
                    },

                    ActionButton {
                        icon: 'cam'
                        onClicked: console.log('cam clicked')
                    }
                ]
            }
        }
    }

    PopupShadow {
        anchors.fill: listContainer
        source: listContainer
        visible: true
    }
}
