import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================

Row {
	property int childrenCount: children.length
  property double maxItemWidth: {
    var n = childrenCount
    var curWidth = width / n - (n - 1) * spacing
    var maxWidth = orientation === Qt.Horizontal
      ? FormHGroupStyle.legend.width + FormHGroupStyle.content.maxWidth + FormHGroupStyle.spacing
      : FormVGroupStyle.content.maxWidth

    return curWidth < maxWidth ? curWidth : maxWidth
  }
  readonly property int orientation: parent.orientation

  // ---------------------------------------------------------------------------

  spacing: FormLineStyle.spacing
  width: parent.width
}
