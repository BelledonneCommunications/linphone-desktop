import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// =============================================================================
// Responsive flat menu with visual indicators.
// =============================================================================

Rectangle {
  id: menu

  // ---------------------------------------------------------------------------

  property int entryHeight
  property int entryWidth
  property var entries

  property int _selectedEntry: 0

  // ---------------------------------------------------------------------------

  signal entrySelected (int entry)

  // ---------------------------------------------------------------------------

  function setSelectedEntry (entry) {
    _selectedEntry = entry
  }

  function resetSelectedEntry () {
    _selectedEntry = -1
  }

  // ---------------------------------------------------------------------------

  color: ApplicationMenuStyle.backgroundColor
  implicitHeight: content.height
  width: entryWidth

  ColumnLayout {
    id: content

    anchors.centerIn: parent
    spacing: ApplicationMenuStyle.spacing

    Repeater {
      model: entries

      Rectangle {
        color: mouseArea.pressed
          ? ApplicationMenuStyle.entry.color.pressed
          : (_selectedEntry === index
             ? ApplicationMenuStyle.entry.color.selected
             : (mouseArea.containsMouse
                ? ApplicationMenuStyle.entry.color.hovered
                : ApplicationMenuStyle.entry.color.normal
               )
            )
        height: menu.entryHeight
        width: menu.entryWidth

        RowLayout {
          anchors {
            left: parent.left
            leftMargin: ApplicationMenuStyle.entry.leftMargin
            right: parent.right
            rightMargin: ApplicationMenuStyle.entry.rightMargin
            verticalCenter: parent.verticalCenter
          }

          spacing: ApplicationMenuStyle.entry.spacing

          Icon {
            icon: modelData.icon + (
              _selectedEntry === index
                ? '_selected'
                : '_normal'
            )
            iconSize: ApplicationMenuStyle.entry.iconSize
          }

          Text {
            Layout.fillWidth: true
            color: _selectedEntry === index
              ? ApplicationMenuStyle.entry.text.color.selected
              : ApplicationMenuStyle.entry.text.color.normal
            font.pointSize: ApplicationMenuStyle.entry.text.pointSize
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
            ? ApplicationMenuStyle.entry.indicator.color
            : 'transparent'
          width: ApplicationMenuStyle.entry.indicator.width
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
