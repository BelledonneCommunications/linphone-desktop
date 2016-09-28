import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import Linphone 1.0

ScrollableListView {
    model: ListModel {
        ListElement { $dateSection: 1465389121000; $outgoing: true; $timestamp: 1465389121000; $type: 'message'; $content: 'This is it: fefe efzzzzzzzzzz aaaaaaaaa erfeezffeefzfzefzefzezfefez wfef efef  e efeffefe fee efefefeefef fefefefefe eff fefefe fefeffww.linphone.org' }
        ListElement { $dateSection: 1465389121000; $timestamp: 1465389121000; $type: 'event'; $content: 'incoming_call' }
        ListElement { $dateSection: 1465389121000; $timestamp: 1465389421000; $type: 'message'; $content: 'Perfect!' }
        ListElement { $dateSection: 1465389121000; $timestamp: 1465389121000; $type: 'event'; $content: 'hangup' }
        ListElement { $dateSection: 1465994221000; $outgoing: true; $timestamp: 1465994221000; $type: 'message'; $content: 'You\'ve heard the expression, "Just believe it and it will come." Well, technically, that is true, however, \'believing\' is not just thinking that you can have it...' }
        ListElement { $dateSection: 1465994221000; $timestamp: 1465994221000; $type: 'event'; $content: 'lost_incoming_call' }
    }

    Component {
        id: sectionHeading

        Item {
            implicitHeight: text.height +
                container.anchors.topMargin +
                container.anchors.bottomMargin
            width: parent.width

            Item {
                anchors.bottomMargin: 10
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.topMargin: 20
                id: container

                Text {
                    color: '#434343'
                    font.bold: true
                    id: text

                    // Cast section to integer because Qt convert the
                    // $dateSection in string!!!
                    text: new Date(+section).toLocaleDateString(
                        Qt.locale()
                    )
                }
            }
        }
    }

    section.criteria: ViewSection.FullString
    section.delegate: sectionHeading
    section.property: '$dateSection'

    delegate: Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.right: parent.right
        anchors.rightMargin: 18

        // Unable to use `height` property.
        // The height is given by message height.
        implicitHeight: layout.height + 10
        width: parent.width

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.state = 'hover'
            onExited: parent.state = ''
        }

        RowLayout {
            id: layout
            spacing: 0

            // The height is computed with the message height.
            // Unable to use `height` and `implicitHeight` property.
            width: parent.width

            // Display time.
            Text {
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: 30
                Layout.preferredWidth: 50
                color: '#898989'
                font.bold: $type === 'event'
                text: new Date($timestamp).toLocaleString(
                    Qt.locale(),
                    'hh:mm'
                )
                verticalAlignment: Text.AlignVCenter
            }

            // Icons area.
            Row {
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: 30
                Layout.preferredWidth: 54
                spacing: 10

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: ($type === 'event' && $content) || ''
                    iconSize: 16
                }

                ActionButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: 'delete'
                    iconSize: 16
                    id: removeAction
                    onClicked: console.log('remove item')
                    visible: false
                }
            }

            // Display content.
            Loader {
                Layout.fillWidth: true
                id: loader
                source: $type === 'message'
                    ? (
                        'qrc:/ui/modules/Linphone/Chat/' +
                            ($outgoing ? 'Outgoing' : 'Incoming') +
                            'Message.qml'
                    ) : 'qrc:/ui/modules/Linphone/Chat/Event.qml'
            }
        }

        states: State {
            name: 'hover'
            PropertyChanges { target: removeAction; visible: true }
        }
    }
}
