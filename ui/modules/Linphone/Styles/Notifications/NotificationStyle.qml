pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property color color: Colors.k
  property int height: 120
  property int iconSize: 40
  property int width: 300

  property QtObject border: QtObject {
    property color color: Colors.w
    property int width: 1
  }
}
