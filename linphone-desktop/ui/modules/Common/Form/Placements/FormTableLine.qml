import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

// =============================================================================

Row {
  id: formTableLine

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
    width: formTableLine.parent.legendLineWidth

    font {
      bold: false
      pointSize: FormTableStyle.entry.text.pointSize
    }

    visible: !formTableLine.parent.disableLineTitle
  }
}
