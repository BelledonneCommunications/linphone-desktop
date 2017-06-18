pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property int buttonsSpacing: 8

  property QtObject button: QtObject {
    property QtObject color: QtObject {
      property color hovered: Colors.n
      property color normal: Colors.m
      property color pressed: Colors.i
      property color selected: Colors.g
    }
  }
}
