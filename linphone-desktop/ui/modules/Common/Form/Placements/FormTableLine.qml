import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

// =============================================================================

Row {
  property alias title: title.text
  readonly property double maxItemWidth: parent.maxItemWidth

  // ---------------------------------------------------------------------------

  spacing: FormLineStyle.spacing
  width: parent.width

  // ---------------------------------------------------------------------------

  Text {
    id: title

    color: FormTableStyle.entry.text.color
    elide: Text.ElideRight

    horizontalAlignment: Text.AlignRight
    verticalAlignment: Text.AlignVCenter

    height: FormTableStyle.entry.height
    width: FormTableStyle.entry.width

    font {
      bold: false
      pointSize: FormTableStyle.entry.text.fontSize
    }
  }
}
