pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property QtObject tools: QtObject {
    property int width: 20

    property QtObject button: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.q
        property color pressed: Colors.c
      }

      property QtObject text: QtObject {
        property color color: Colors.d
        property int pointSize: Units.dp * 9
      }
    }
  }
}
