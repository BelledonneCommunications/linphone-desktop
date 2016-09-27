import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import Linphone 1.0

import 'qrc:/ui/scripts/utils.js' as Utils

ColumnLayout {
    spacing: 2

    // Search bar.
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.right: parent.right
        anchors.rightMargin: 18

        RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            height: 30
            spacing: 20
            width: parent.width

            // TODO: Replace by top-level component.
            TextField {
                Layout.fillWidth: true
                background: Rectangle {
                    color: '#EAEAEA'
                    implicitHeight: 30
                }
                placeholderText: qsTr('searchContactPlaceholder')
            }

            ExclusiveButtons {
                texts: [
                    qsTr('selectAllContacts'),
                    qsTr('selectConnectedContacts')
                ]
            }

            TextButtonB {
                text: qsTr('addContact')
            }
        }
    }

    // Contacts list.
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: '#F5F5F5'

        ScrollableListView {
            anchors.fill: parent
            spacing: 2

            // TODO: Remove, use C++ model instead.
            model: ListModel {
                ListElement {
                    $image: ''
                    $presence: 'connected'
                    $username: 'Isabella Ahornton'
                }
                ListElement {
                    $image: ''
                    $presence: 'connected'
                    $username: 'Mary Boreno'
                }
                ListElement {
                    $image: ''
                    $presence: 'disconnected'
                    $username: 'Cecelia Cyler'
                }
                ListElement {
                    $image: ''
                    $presence: 'absent'
                    $username: 'Daniel Elliott'
                }
                ListElement {
                    $image: ''
                    $presence: 'do_not_disturb'
                    $username: 'Effie Forton'
                }
                ListElement {
                    $image: ''
                    $presence: 'do_not_disturb'
                    $username: 'Agnes Hurner'
                }
                ListElement {
                    $image: ''
                    $presence: 'disconnected'
                    $username: 'Luke Leming'
                }
                ListElement {
                    $image: ''
                    $presence: 'connected'
                    $username: 'Olga Manning'
                }
                ListElement {
                    $image: ''
                    $presence: 'connected'
                    $username: 'Isabella Ahornton'
                }
                ListElement {
                    $image: ''
                    $presence: 'connected'
                    $username: 'Mary Boreno'
                }
                ListElement {
                    $image: ''
                    $presence: 'disconnected'
                    $username: 'Cecelia Cyler'
                }
                ListElement {
                    $image: ''
                    $presence: 'disconnected'
                    $username: 'Toto'
                }
                ListElement {
                    $image: ''
                    $presence: 'absent'
                    $username: 'Daniel Elliott'
                }
                ListElement {
                    $image: ''
                    $presence: 'do_not_disturb'
                    $username: 'Effie Forton'
                }
                ListElement {
                    $image: ''
                    $presence: 'do_not_disturb'
                    $username: 'Agnes Hurner'
                }
                ListElement {
                    $image: ''
                    $presence: 'disconnected'
                    $username: 'Luke Leming'
                }
                ListElement {
                    $image: ''
                    $presence: 'connected'
                    $username: 'Olga Manning'
                }
            }
            delegate: Rectangle {
                color: '#FFFFFF'
                height: 50
                id: contact
                width: parent.width

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: contact.state = 'hover'
                    onExited: contact.state = ''
                }

                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    height: 30
                    width: parent.width

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 25
                        spacing: 15

                        // Avatar.
                        Avatar {
                            Layout.fillHeight: parent.height
                            Layout.preferredWidth: 30
                            image: $image
                            username: $username
                        }

                        // Presence.
                        Item {
                            Layout.fillHeight: parent.height
                            Layout.preferredWidth: 20

                            Image {
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                source: 'qrc:/imgs/led_' + $presence + '.svg'
                            }
                        }

                        // Username.
                        Item {
                            Layout.fillHeight: parent.height
                            Layout.fillWidth: true

                            Text {
                                anchors.fill: parent
                                clip: true
                                color: '#5A585B'
                                font.bold: true
                                text: $username
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Actions.
                        Row {
                            Layout.fillHeight: true
                            id: actions
                            spacing: 50
                            visible: false

                            ActionBar {
                                iconSize: parent.height

                                ActionButton {
                                    icon: 'cam'
                                }

                                ActionButton {
                                    icon: 'call'
                                }

                                ActionButton {
                                    icon: 'chat'
                                }
                            }

                            ActionButton {
                                iconSize: parent.height
                                icon: 'delete'
                                onClicked: Utils.openConfirmDialog(contact, {
                                    descriptionText: qsTr('removeContactDescription'),
                                    exitHandler: function (status) {
                                        console.log('remove contact', status)
                                    },
                                    title: qsTr('removeContactTitle')
                                })
                            }
                        }
                    }
                }

                states: State {
                    name: 'hover'
                    PropertyChanges { target: contact; color: '#D1D1D1' }
                    PropertyChanges { target: actions; visible: true }
                }
            }
        }
    }
}
