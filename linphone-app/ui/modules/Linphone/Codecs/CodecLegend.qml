import QtQuick 2.7

import Linphone.Styles 1.0

// =============================================================================

Text {
  color: CodecsViewerStyle.legend.colorModel.color
  elide: Text.ElideRight

  font {
    bold: true
    pointSize: CodecsViewerStyle.legend.pointSize
  }
}
