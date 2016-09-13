import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import 'qrc:/ui/components/contact'
import 'qrc:/ui/components/form'
import 'qrc:/ui/components/scrollBar'

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

            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height
                background: Rectangle {
                    color: '#EAEAEA'
                }
                placeholderText: qsTr('searchContactPlaceholder')
            }

            ExclusiveButtons {
                Layout.preferredHeight: parent.height
                text1: qsTr('selectAllContacts')
                text2: qsTr('selectConnectedContacts')
            }

            LightButton {
                Layout.preferredHeight: parent.height
                text: qsTr('addContact')
            }
        }
    }

    // Contacts list.
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: '#F5F5F5'

        ListView {
            ScrollBar.vertical: ForceScrollBar { }
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            highlightRangeMode: ListView.ApplyRange
            spacing: 1

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

                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    height: 30
                    width: parent.width

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
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
                                font.weight: Font.DemiBold
                                text: $username
                                verticalAlignment: Text.AlignVCenter

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: contact.state = 'hover'
                                    onExited: contact.state = ''
                                }
                            }
                        }

                        // Actions.
                        // TODO.
                    }
                }

                states: State {
                    name: 'hover'
                    PropertyChanges { target: contact; color: '#D1D1D1' }
                }
            }
        }
    }
}
