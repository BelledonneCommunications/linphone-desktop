pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
  property int transitionDuration: 200

  property QtObject handle: QtObject {
    property int width: 5

    property QtObject color: QtObject {
      property color hovered: Colors.h.color
      property color normal: Colors.c.color
      property color pressed: Colors.d.color
    }
  }
}
