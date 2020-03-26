import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================

Column {
  id: formTable

  property alias titles: header.model
  property bool disableLineTitle: false

  property int legendLineWidth: FormTableStyle.entry.width

  readonly property double maxItemWidth: {
    var n = titles.length
    var curWidth = (width - FormTableStyle.entry.width) / n - (n - 1) * FormTableLineStyle.spacing
    var maxWidth = FormTableStyle.entry.maxWidth

    return curWidth < maxWidth ? curWidth : maxWidth
  }

  // ---------------------------------------------------------------------------

  spacing: FormTableStyle.spacing
  width: parent.width

  // ---------------------------------------------------------------------------

  Row {
    spacing: FormTableLineStyle.spacing
    width: parent.width

    // No title for the titles column.
    Item {
      height: FormTableStyle.entry.height
      width: formTable.legendLineWidth

      visible: !formTable.disableLineTitle
    }

    Repeater {
      id: header

      Text {
        id: text

        color: FormTableStyle.entry.text.color
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        text: modelData
        height: FormTableStyle.entry.height
        width: formTable.maxItemWidth

        font {
          bold: true
          pointSize: FormTableStyle.entry.text.pointSize
        }
      }
    }
  }
}
