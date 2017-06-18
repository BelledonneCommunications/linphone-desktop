pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

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
    property int pointSize: Units.dp * 7
  }
}
