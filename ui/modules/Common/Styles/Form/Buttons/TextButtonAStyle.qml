pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property QtObject backgroundColor: QtObject {
    property color disabled: Colors.o
    property color hovered: Colors.o
    property color normal: Colors.j
    property color pressed: Colors.i
  }

  property QtObject textColor: QtObject {
    property color disabled: Colors.k
    property color hovered: Colors.k
    property color normal: Colors.k
    property color pressed: Colors.k
  }
}
