import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================

Column {
  id: formTable
  
   width: parent.width

  property alias titles: header.model
  property bool disableLineTitle: false

  property int legendLineWidth: FormTableStyle.entry.width
  
  property var maxWidthStyle : FormTableStyle.entry.maxWidth

  readonly property double maxItemWidth: {
    var n = titles.length
    var curWidth = (width - (disableLineTitle?0:legendLineWidth) ) /n  - FormTableLineStyle.spacing
    var maxWidth = maxWidthStyle
    return curWidth < maxWidth ? curWidth : maxWidth
  }

  // ---------------------------------------------------------------------------

  spacing: FormTableStyle.spacing

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
