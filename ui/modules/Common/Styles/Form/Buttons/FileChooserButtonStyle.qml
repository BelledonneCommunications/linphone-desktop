pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property QtObject tools: QtObject {
    property int width: 30

    property QtObject button: QtObject {
      property int iconSize: 16

      property QtObject color: QtObject {
        property color hovered: Colors.c
        property color normal: Colors.q
        property color pressed: Colors.c
      }
    }
  }
}
