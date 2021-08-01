pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.d.color

  property QtObject initials: QtObject {
    property color color: Colors.q.color
    property int pointSize: Units.dp * 10
    property int ratio: 30
  }
}
