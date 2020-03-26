pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property QtObject iconSize: QtObject {
    property int amount: 16
    property int message: 18
  }

  property QtObject text: QtObject {
    property color color: Colors.q
    property int pointSize: Units.dp * 7
  }
}
