pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property int spacing: 5

  property QtObject content: QtObject {
    property int maxWidth: 400
  }

  property QtObject error: QtObject {
    property color color: Colors.error.color
    property int pointSize: Units.dp * 10
    property int height: 11
  }

  property QtObject legend: QtObject {
    property color color: Colors.j.color
    property int pointSize: Units.dp * 10
  }
}
