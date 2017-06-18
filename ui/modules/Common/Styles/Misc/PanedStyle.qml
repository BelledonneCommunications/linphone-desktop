pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property int transitionDuration: 200

  property QtObject handle: QtObject {
    property int width: 5

    property QtObject color: QtObject {
      property color hovered: Colors.h
      property color normal: Colors.c
      property color pressed: Colors.b
    }
  }
}
