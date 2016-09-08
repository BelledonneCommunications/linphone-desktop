import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import 'qrc:/ui/components/form'

Window {
    id: window
    minimumHeight: 328
    minimumWidth: 480
    modality: Qt.WindowModal
    title: qsTr('manageAccountsTitle')

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Window description.
        Item {
            Layout.alignment : Qt.AlignTop
            Layout.fillWidth: true
            height: 90

            Text {
                anchors.fill: parent
                anchors.leftMargin: 50
                anchors.rightMargin: 50
                font.pointSize: 12
                text: qsTr('manageAccountsDescription')
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
            }
        }

        // Accounts list.
        Item {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.fillWidth: true
            id: listViewContainer

            ListView {
                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                highlightRangeMode: ListView.ApplyRange
                id: accountsList
                spacing: 0
                horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOn
                // TODO: Remove, use C++ model instead.
                model: ListModel {
                    ListElement {
                        presence: 'connected'
                        sipAddress: 'jim.williams.zzzz.yyyy.kkkk.sip.linphone.org'
                        isDefault: false
                    }
                    ListElement {
                        presence: 'connected'
                        sipAddress: 'toto.lala.sip.linphone.org'
                        isDefault: false
                    }
                    ListElement {
                        presence: 'disconnected'
                        sipAddress: 'machin.truc.sip.linphone.org'
                        isDefault: true
                    }
                    ListElement {
                        presence: 'absent'
                        sipAddress: 'hey.listen.sip.linphone.org'
                        isDefault: false
                    }
                    ListElement {
                        presence: 'do_not_disturb'
                        sipAddress: 'valentin.cognito.sip.linphone.org'
                        isDefault: false
                    }
                    ListElement {
                        presence: 'do_not_disturb'
                        sipAddress: 'charles.henri.sip.linphone.org'
                        isDefault: false
                    }
                    ListElement {
                        presence: 'disconnected'
                        sipAddress: 'yesyes.nono.sip.linphone.org'
                        isDefault: false
                    }
                    ListElement {
                        presence: 'connected'
                        sipAddress: 'nsa.sip.linphone.org'
                        isDefault: false
                    }
                }
                delegate: Item {
                    height: 34
                    width: parent.width

                    Rectangle {
                        anchors.fill: parent
                        color: isDefault ? '#EAEAEA' : 'transparent'
                        id: accountLine

                        RowLayout {
                            anchors.fill: parent
                            spacing: 15
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15

                            // Default account.
                            Item {
                                Layout.fillHeight: parent.height
                                Layout.preferredWidth: 20

                                Image {
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectFit
                                    source: isDefault ? 'qrc:/imgs/valid.svg' : ''
                                }
                            }

                            // Sip account.
                            Item {
                                Layout.fillHeight: parent.height
                                Layout.fillWidth: true

                                Text {
                                    anchors.fill: parent
                                    clip: true
                                    color: '#59575A'
                                    text: sipAddress;
                                    verticalAlignment: Text.AlignVCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }

                            // Presence.
                            Item {
                                Layout.fillHeight: parent.height
                                Layout.preferredWidth: 20

                                Image {
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectFit
                                    source: 'qrc:/imgs/led_' + presence + '.svg'
                                }
                            }

                            // Update presence.
                            Item {
                                Layout.fillHeight: parent.height
                                Layout.preferredWidth: 160

                                DialogComboBox {
                                    anchors.fill: parent
                                    model: ListModel {
                                        ListElement { key: qsTr('onlinePresence'); value: 1 }
                                        ListElement { key: qsTr('busyPresence'); value: 2 }
                                        ListElement { key: qsTr('beRightBackPresence'); value: 3 }
                                        ListElement { key: qsTr('awayPresence'); value: 4 }
                                        ListElement { key: qsTr('onThePhonePresence'); value: 5 }
                                        ListElement { key: qsTr('outToLunchPresence'); value: 6 }
                                        ListElement { key: qsTr('doNotDisturbPresence'); value: 7 }
                                        ListElement { key: qsTr('movedPresence'); value: 8 }
                                        ListElement { key: qsTr('usingAnotherMessagingServicePresence'); value: 9 }
                                        ListElement { key: qsTr('offlinePresence'); value: 10 }
                                    }
                                    textRole: 'key'
                                }
                            }
                        }
                    }
                }
            }
        }

        // Validate
        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            height: 100

            DialogButton {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 30
                anchors.left: parent.left
                anchors.leftMargin: 54
                text: qsTr('validate')
            }
        }
    }
}
