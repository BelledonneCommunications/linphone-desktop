import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================
// Display a title on a `FormGroup`.
// Must be used in a `FormHeader`.
// =============================================================================

Item {
  property alias text: text.text

  height: parent.height
  width: FormGroupStyle.spacing + FormGroupStyle.legend.width + FormGroupStyle.content.width

  Text {
    id: text

    anchors {
      fill: parent
      leftMargin: FormGroupStyle.spacing + FormGroupStyle.legend.width
    }

    color: FormHeaderGroupStyle.text.color
    elide: Text.ElideRight
    font {
      bold: true
      pointSize: FormHeaderGroupStyle.text.fontSize
    }

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }
}
