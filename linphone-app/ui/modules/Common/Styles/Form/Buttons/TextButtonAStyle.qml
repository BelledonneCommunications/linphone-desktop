pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property QtObject backgroundColor: QtObject {
    property color disabled: Colors.o
    property color hovered: Colors.j
    property color normal: Colors.g
    property color pressed: Colors.i
  }

  property QtObject textColor: QtObject {
    property color disabled: Colors.q
    property color hovered: Colors.q
    property color normal: Colors.q
    property color pressed: Colors.q
  }
}
