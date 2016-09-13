import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import 'qrc:/ui/components/contact'
import 'qrc:/ui/components/form'
import 'qrc:/ui/components/scrollBar'

ColumnLayout  {
    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 102
        color: '#D1D1D1'

        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.verticalCenter: parent.verticalCenter
            height: 80
            spacing: 50
            width: parent.width

            Avatar {
                Layout.fillHeight: true
                Layout.preferredWidth: 80
                presence: 'connected' // TODO: Use C++.
                username: 'Cameron Andrews' // TODO: Use C++.
            }

            Column {
                Layout.fillHeight: true
                Layout.fillWidth: true

                // Contact description.
                ShortContactDescription {
                    height: parent.height * 0.60
                    sipAddress: 'cam.andrews@sip.linphone.org' // TODO: Use C++.
                    username: 'Cameron Andrews' // TODO: Use C++.
                    width: parent.width
                }

                // Contact actions.
                Row {
                    height: parent.height * 0.40
                    width: parent.width

                    Row {
                        height: parent.height
                        spacing: 10
                        width: parent.width / 2

                        Rectangle {
                            color: 'blue'
                            width: 32
                            height: 32
                        }

                        Rectangle {
                            color: 'red'
                            width: 32
                            height: 32
                        }
                    }

                    Row {
                        height: parent.height
                        layoutDirection: Qt.RightToLeft
                        spacing: 10
                        width: parent.width / 2

                        Rectangle {
                            color: 'green'
                            width: 32
                            height: 32
                        }

                        Rectangle {
                            color: 'orange'
                            width: 32
                            height: 32
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        color: '#C7C7C7'

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 1

            ExclusiveButtons {
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.verticalCenter: parent.verticalCenter
                texts: [
                    qsTr('displayCallsAndMessages'),
                    qsTr('displayCalls'),
                    qsTr('displayMessages')
                ]
            }
        }
    }

    Rectangle {
        Layout.fillHeight: true
        Layout.fillWidth: true
        border.color: '#C7C7C7'
        border.width: 1
        id: messagesArea

        ListView {
            ScrollBar.vertical: ForceScrollBar { }
            anchors.fill: parent
            anchors.bottomMargin: messagesArea.border.width
            anchors.topMargin: messagesArea.border.width
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            highlightRangeMode: ListView.ApplyRange
            spacing: 1
        }
    }

    // Send area.
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 70
        border.color: textArea.activeFocus ? '#8E8E8E' : '#C7C7C7'
        border.width: 1
        id: newMessageArea

        RowLayout {
            anchors.fill: parent

            Flickable {
                Layout.preferredHeight: parent.height
                Layout.fillWidth: true
                ScrollBar.vertical: ScrollBar { }
                TextArea.flickable: TextArea {
                    id: textArea
                    placeholderText: qsTr('newMessagePlaceholder')
                    wrapMode: TextArea.Wrap
                }
            }

            DropZone {
                Layout.preferredHeight: parent.height - newMessageArea.border.width * 2
                Layout.preferredWidth: 40
            }
        }
    }
}
