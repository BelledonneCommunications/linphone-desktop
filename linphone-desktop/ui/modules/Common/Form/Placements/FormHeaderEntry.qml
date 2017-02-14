import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================
// Display a title on a `FormEntry`.
// Must be used in a `FormHeader`.
// =============================================================================

Item {
  property alias text: text.text

  height: parent.height
  width: FormGroupStyle.content.width

  Text {
    id: text

    anchors.centerIn: parent
    color: FormHeaderGroupStyle.text.color
    elide: Text.ElideRight

    font {
      bold: true
      pointSize: FormHeaderGroupStyle.text.fontSize
    }
  }
}
