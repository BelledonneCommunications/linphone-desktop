import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

// ===================================================================
// Responsive flat menu with visual indicators.
// ===================================================================

ColumnLayout {
  id: menu

  property int entryHeight
  property int entryWidth
  property var entries

  property int fontSize: MenuStyle.entry.text.fontSize

  property int _selectedEntry: 0

  signal entrySelected (int entry)

  spacing: MenuStyle.spacing

  Repeater {
    model: entries

    Rectangle {
      color: mouseArea.pressed
        ? MenuStyle.entry.color.pressed
        : (_selectedEntry === index
           ? MenuStyle.entry.color.selected
           : (mouseArea.containsMouse
              ? MenuStyle.entry.color.hovered
              : MenuStyle.entry.color.normal
             )
          )
      height: menu.entryHeight
      width: menu.entryWidth

      RowLayout {
        anchors {
          left: parent.left
          leftMargin: MenuStyle.entry.leftMargin
          right: parent.right
          rightMargin: MenuStyle.entry.rightMargin
          verticalCenter: parent.verticalCenter
        }

        spacing: MenuStyle.entry.spacing

        Icon {
          Layout.preferredHeight: modelData.icon
            ? (modelData.iconSize != null
               ? modelData.iconSize
               : MenuStyle.entry.iconSize
              ) : 0
          Layout.preferredWidth: modelData.icon
            ? (modelData.iconSize != null
               ? modelData.iconSize
               : MenuStyle.entry.iconSize
              ) : 0
          icon: modelData.icon || ''
        }

        Text {
          Layout.fillWidth: true
          color: MenuStyle.entry.text.color
          font.pointSize: menu.fontSize
          height: parent.height
          text: modelData.entryName
          verticalAlignment: Text.AlignVCenter
        }

        Icon {
          Layout.alignment: Qt.AlignRight
          Layout.preferredHeight: MenuStyle.entry.selectionIconSize
          Layout.preferredWidth: MenuStyle.entry.selectionIconSize
          icon: _selectedEntry === index
            ? 'right_arrow'
            : ''
        }
      }

      MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
          _selectedEntry = index
          entrySelected(index)
        }
      }
    }
  }
}
