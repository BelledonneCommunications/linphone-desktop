pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property color color: Colors.k
  property int height: 120
  property int iconSize: 40
  property int spacing: 0
  property int width: 300
  property int bottomMargin: 15
  property int leftMargin: 15
  property int rightMargin: 15

  property QtObject actionArea: QtObject {
    property int iconSize: 40
    property int rightButtonsGroupMargin: 15
  }
}
