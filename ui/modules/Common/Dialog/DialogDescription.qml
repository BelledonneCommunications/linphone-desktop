import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================
// Description content used by dialogs.
// =============================================================================

Item {
  property alias text: description.text

  height: !text ? DialogStyle.description.verticalMargin : undefined
  implicitHeight: text
    ? description.implicitHeight + DialogStyle.description.verticalMargin * 2
    : 0

  Text {
    id: description

    anchors {
      fill: parent
      leftMargin: DialogStyle.description.leftMargin
      rightMargin: DialogStyle.description.rightMargin
    }

    color: DialogStyle.description.color
    font.pointSize: DialogStyle.description.pointSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    wrapMode: Text.WordWrap
  }
}
