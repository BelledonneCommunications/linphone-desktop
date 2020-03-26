pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int spacing: 20

  property QtObject content: QtObject {
    property int maxWidth: 400
  }

  property QtObject legend: QtObject {
    property color color: Colors.j
    property int pointSize: Units.dp * 10
    property int height: 36
    property int width: 200
  }
}
