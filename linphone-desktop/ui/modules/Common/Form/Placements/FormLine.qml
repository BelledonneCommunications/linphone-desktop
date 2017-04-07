import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================

Row {
  readonly property double maxItemWidth: {
    var n = children.length
    var curWidth = width / n - (n - 1) * spacing
    var maxWidth = orientation === Qt.Horizontal
      ? FormHGroupStyle.legend.width + FormHGroupStyle.content.maxWidth + FormHGroupStyle.spacing
      : FormVGroupStyle.content.maxWidth

    return curWidth < maxWidth ? curWidth : maxWidth
  }
  readonly property int orientation: parent.orientation
  readonly property bool dealWithErrors: parent.dealWithErrors

  // ---------------------------------------------------------------------------

  spacing: FormLineStyle.spacing
  width: parent.width
}
