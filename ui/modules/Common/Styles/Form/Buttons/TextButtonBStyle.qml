pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property QtObject backgroundColor: QtObject {
    property color disabled: Colors.i30
    property color hovered: Colors.b
    property color normal: Colors.i
    property color pressed: Colors.m
  }

  property QtObject textColor: QtObject {
    property color disabled: Colors.k
    property color hovered: Colors.k
    property color normal: Colors.k
    property color pressed: Colors.k
  }
}
