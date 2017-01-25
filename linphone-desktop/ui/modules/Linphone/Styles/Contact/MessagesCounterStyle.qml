pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int horizontalMargins: 0
  property int verticalMargins: 10

  property QtObject iconSize: QtObject {
    property int amount: 16
    property int message: 18
  }

  property QtObject text: QtObject {
    property color color: Colors.k
    property int fontSize: 7
  }
}
