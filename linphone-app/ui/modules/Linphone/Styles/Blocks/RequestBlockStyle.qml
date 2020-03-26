pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int height: 60

  property QtObject error: QtObject {
    property color color: Colors.error
    property int pointSize: Units.dp * 11
    property int padding: 4
  }

  property QtObject loadingIndicator: QtObject {
    property int height: 20
    property int width: 20
  }
}
