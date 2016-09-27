import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0

import Linphone 1.0

// TODO: Contacts list.
Item {
    function setPopupVisibility (visibility) {
        popup.visible = true
    }

    function filterContacts (text) {
        console.log(text)
    }

    TextField {
        placeholderText: qsTr('contactSearch')
        background: Rectangle {
            implicitHeight: 40
            border.color: '#CBCBCB'
            border.width: 2
            color: '#FFFFFF'
        }
        id: textField
        width: parent.width

        onFocusChanged: setPopupVisibility(focus)
        onTextChanged: filterContacts(text)
    }

    Rectangle {
        anchors.top: textField.bottom
        anchors.topMargin: 2
        border.color: '#9B9B9B'
        color: '#EAEAEA'
        height: parent.height - textField.height // Avoid overflow.
        id: popup
        visible: false
        width: parent.width

        ScrollableListView {
            anchors.fill: parent
            id: contactsList

            // TODO: Remove, use C++ model instead.
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

    DropShadow {
        anchors.fill: popup
        color: "#80000000"
        horizontalOffset: 0
        id: popupShadow
        radius: 8.0
        samples: 15
        source: popup
        verticalOffset: 2
        visible: false
    }
}
