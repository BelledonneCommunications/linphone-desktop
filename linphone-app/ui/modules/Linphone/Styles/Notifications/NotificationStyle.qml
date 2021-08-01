pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
  property color color: Colors.k.color
  property int height: 120
  property int iconSize: 40
  property int width: 300

  property QtObject border: QtObject {
    property color color: Colors.n.color
    property int width: 1
  }
}
