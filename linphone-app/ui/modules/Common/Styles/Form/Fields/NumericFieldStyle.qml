pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property QtObject tools: QtObject {
    property int width: 20

    property QtObject button: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.f.color
        property color pressed: Colors.c.color
      }

      property QtObject text: QtObject {
        property color color: Colors.d.color
        property int pointSize: Units.dp * 9
      }
    }
  }
}
