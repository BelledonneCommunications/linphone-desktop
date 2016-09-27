import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone 1.0

// ===================================================================
// Responsive flat menu with visual indicators.
// ===================================================================

ColumnLayout {
    id: item

    property int entryHeight
    property int entryWidth
    property variant entries

    property int _selectedEntry: 0

    signal entrySelected (int entry)

    spacing: 2

    Repeater {
        model: entries

        Rectangle {
            color: _selectedEntry === index
                ? '#434343'
                : (mouseArea.pressed
                   ? '#FE5E00'
                   : (mouseArea.containsMouse
                      ? '#707070'
                      : '#8E8E8E'
                     )
                  )
            height: item.entryHeight
            width: item.entryWidth

            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                spacing: 18

                Icon {
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 24
                    icon: modelData.icon
                }

                Text {
                    Layout.fillWidth: true
                    color: '#FFFFFF'
                    font.pointSize: 13
                    height: parent.height
                    text: modelData.entryName
                    verticalAlignment: Text.AlignVCenter
                }

                Icon {
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredHeight: 12
                    Layout.preferredWidth: 12
                    icon: _selectedEntry === index ? 'right_arrow' : ''
                }
            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    if (_selectedEntry !== index) {
                        _selectedEntry = index
                        entrySelected(index)
                    }
                }
            }
        }
    }
}
