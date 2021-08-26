pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
  property QtObject tools: QtObject {
    property int width: 30

    property QtObject button: QtObject {
      property int iconSize: 16

      property QtObject color: QtObject {
        property color hovered: Colors.c.color
        property color normal: Colors.f.color
        property color pressed: Colors.c.color
      }
    }
  }
}
