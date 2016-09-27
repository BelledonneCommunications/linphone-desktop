import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone 1.0
import Linphone.Styles 1.0

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

    spacing: MenuStyle.spacing

    Repeater {
        model: entries

        Rectangle {
            color: _selectedEntry === index
                ? MenuStyle.entry.color.selected
                : (mouseArea.pressed
                   ? MenuStyle.entry.color.pressed
                   : (mouseArea.containsMouse
                      ? MenuStyle.entry.color.hovered
                      : MenuStyle.entry.color.normal
                     )
                  )
            height: item.entryHeight
            width: item.entryWidth

            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: MenuStyle.entry.leftMargin
                anchors.right: parent.right
                anchors.rightMargin: MenuStyle.entry.rightMargin
                anchors.verticalCenter: parent.verticalCenter
                spacing: MenuStyle.entry.spacing

                Icon {
                    Layout.preferredHeight: MenuStyle.entry.iconSize
                    Layout.preferredWidth: MenuStyle.entry.iconSize
                    icon: modelData.icon
                }

                Text {
                    Layout.fillWidth: true
                    color: MenuStyle.entry.text.color
                    font.pointSize: MenuStyle.entry.text.fontSize
                    height: parent.height
                    text: modelData.entryName
                    verticalAlignment: Text.AlignVCenter
                }

                Icon {
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredHeight: MenuStyle.entry.selectionIconSize
                    Layout.preferredWidth: MenuStyle.entry.selectionIconSize
                    icon: _selectedEntry === index
                        ? MenuStyle.entry.selectionIcon
                        : ''
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
