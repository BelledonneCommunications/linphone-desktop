import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================
// Description content used by dialogs.
// =============================================================================

Item {
  property alias text: description.text
  property alias horizontalAlignment: description.horizontalAlignment
  property int marginOffset: 0

  height: !text ? (DialogStyle.description.verticalMargin + marginOffset) : undefined
  implicitHeight: text
    ? description.implicitHeight + (DialogStyle.description.verticalMargin + marginOffset) * 2
    : 0

  Text {
    id: description

    anchors {
      fill: parent
      leftMargin: DialogStyle.description.leftMargin
      rightMargin: DialogStyle.description.rightMargin
    }

    color: DialogStyle.description.colorModel.color
    font.pointSize: DialogStyle.description.pointSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    wrapMode: Text.Wrap
    elide: Text.ElideRight
  }
}
