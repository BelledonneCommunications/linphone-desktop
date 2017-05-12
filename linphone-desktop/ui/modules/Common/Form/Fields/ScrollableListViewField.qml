import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Rectangle {
  border {
    color: TextFieldStyle.background.border.color.normal
    width: TextFieldStyle.background.border.width
  }

  color: TextFieldStyle.background.color.normal
  radius: TextFieldStyle.background.radius

  ScrollableListView {
    anchors.fill: parent
  }
}
