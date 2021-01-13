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

  readonly property double maxItemWidth: computeMaxItemWidth()

  // ---------------------------------------------------------------------------
  function updateMaxItemWidth(){
    maxItemWidth = computeMaxItemWidth();
  }
  function computeMaxItemWidth(){
      var n = 1;
//        if( titles)
//            n = titles.length
//        else{
           for(var line = 0 ; line < formTable.visibleChildren.length ; ++line){
                var column = formTable.visibleChildren[line].visibleChildren.length;
                n = Math.max(n, column-1);
            }
//        }
        var curWidth = (width - (disableLineTitle?0:legendLineWidth) ) /n  - FormTableLineStyle.spacing
        var maxWidth = maxWidthStyle
        return curWidth < maxWidth ? curWidth : maxWidth
  }
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
