pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property QtObject sipAddress: QtObject {
    property color color: Colors.w
    property int pointSize: Units.dp * 10
  }

  property QtObject username: QtObject {
    property color color: Colors.j
    property int pointSize: Units.dp * 11
  }
}
