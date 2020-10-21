import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Rectangle {
  id: entry

  // ---------------------------------------------------------------------------

  property string icon
  property alias name: text.text

  readonly property bool isSelected: parent.parent._selected === this

  // ---------------------------------------------------------------------------

  signal selected

  // ---------------------------------------------------------------------------

  function select () {
    var menu = parent.parent
    if (menu._selected !== this) {
      menu._selected = this
      selected()
    }
  }

  // ---------------------------------------------------------------------------

  color: mouseArea.pressed
    ? ApplicationMenuStyle.entry.color.pressed
    : (isSelected
       ? ApplicationMenuStyle.entry.color.selected
       : (mouseArea.containsMouse
          ? ApplicationMenuStyle.entry.color.hovered
          : ApplicationMenuStyle.entry.color.normal
         )
      )
  height: parent.parent.entryHeight
  width: parent.parent.entryWidth

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
      icon: entry.icon + (
        entry.isSelected
          ? '_selected'
          : '_normal'
      )
      iconSize: ApplicationMenuStyle.entry.iconSize
    }

    Text {
      id: text

      Layout.fillWidth: true
      color: entry.isSelected
        ? ApplicationMenuStyle.entry.text.color.selected
        : ApplicationMenuStyle.entry.text.color.normal
      font.pointSize: ApplicationMenuStyle.entry.text.pointSize
      height: parent.height
      text: entry.name
      verticalAlignment: Text.AlignVCenter
    }
  }

  Rectangle {
    anchors {
      left: parent.left
    }

    height: parent.height
    color: entry.isSelected
      ? ApplicationMenuStyle.entry.indicator.color
      : 'transparent'
    width: ApplicationMenuStyle.entry.indicator.width
  }

  MouseArea {
    id: mouseArea

    anchors.fill: parent

    onClicked: entry.select()
  }
}
