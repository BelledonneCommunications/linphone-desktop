import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0

import 'qrc:/ui/components/misc'

// TODO: Contacts list.
Item {
    function setPopupVisibility (visibility) {
        popup.visible = popupShadow.visible = visibility
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

        ListView {
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            highlightRangeMode: ListView.ApplyRange
            id: contactsList
            spacing: 0

            // TODO: Remove, use C++ model instead.
            model: ListModel {
                ListElement {
                    _presence: 'connected'
                    _sipAddress: 'jim.williams.zzzz.yyyy.kkkk.sip.linphone.org'
                    _username: 'Toto'
                }
                ListElement {
                    _presence: 'connected'
                    _sipAddress: 'toto.lala.sip.linphone.org'
                    _username: 'Toto'
                }
                ListElement {
                    _presence: 'disconnected'
                    _sipAddress: 'machin.truc.sip.linphone.org'
                    _username: 'Toto'
                }
                ListElement {
                    _presence: 'absent'
                    _sipAddress: 'hey.listen.sip.linphone.org'
                    _username: 'Toto'
                }
                ListElement {
                    _presence: 'do_not_disturb'
                    _sipAddress: 'valentin.cognito.sip.linphone.org'
                    _username: 'Toto'
                }
                ListElement {
                    _presence: 'do_not_disturb'
                    _sipAddress: 'charles.henri.sip.linphone.org'
                    _username: 'Toto'
                }
                ListElement {
                    _presence: 'disconnected'
                    _sipAddress: 'yesyes.nono.sip.linphone.org'
                    _username: 'Toto'
                }
                ListElement {
                    _presence: 'connected'
                    _sipAddress: 'nsa.sip.linphone.org'
                    _username: 'Toto'
                }
            }

            delegate: Contact {
                sipAddress: _sipAddress
                username: _username
                width: parent.width
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
