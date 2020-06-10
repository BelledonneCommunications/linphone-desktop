pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.d

  property QtObject initials: QtObject {
    property color color: Colors.q
    property int pointSize: Units.dp * 10
    property int ratio: 30
  }
}
