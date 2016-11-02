import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// ===================================================================
// Responsive flat menu with visual indicators.
// ===================================================================

Rectangle {
  id: menu

  property int entryHeight
  property int entryWidth
  property var entries

  property int _selectedEntry: 0

  signal entrySelected (int entry)

  // -----------------------------------------------------------------

  function resetSelectedEntry () {
    _selectedEntry = -1
  }

  // -----------------------------------------------------------------

  color: MenuStyle.backgroundColor
  implicitHeight: content.height
  width: entryWidth

  ColumnLayout {
    id: content

    anchors.centerIn: parent
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
            Layout.preferredHeight: MenuStyle.entry.iconSize
            Layout.preferredWidth: MenuStyle.entry.iconSize
            icon: modelData.icon + (
              _selectedEntry === index
                ? '_selected'
                : '_normal'
            )
          }

          Text {
            Layout.fillWidth: true
            color: _selectedEntry === index
              ? MenuStyle.entry.text.color.selected
              : MenuStyle.entry.text.color.normal
            font.pointSize: MenuStyle.entry.text.fontSize
            height: parent.height
            text: modelData.entryName
            verticalAlignment: Text.AlignVCenter
          }
        }

        Rectangle {
          anchors {
            left: parent.left
          }

          height: parent.height
          color: _selectedEntry === index
            ? MenuStyle.entry.indicator.color
            : 'transparent'
          width: MenuStyle.entry.indicator.width
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
}
