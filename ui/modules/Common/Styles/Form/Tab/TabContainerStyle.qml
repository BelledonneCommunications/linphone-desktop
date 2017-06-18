pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property color color: Colors.k
  property int bottomMargin: 30
  property int leftMargin: 30
  property int rightMargin: 40
  property int topMargin: 30

  property QtObject separator: QtObject {
    property int height: 2
    property color color: Colors.u
  }
}
