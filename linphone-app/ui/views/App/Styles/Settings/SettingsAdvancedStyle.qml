pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0
// =============================================================================

QtObject {
  property QtObject buttons: QtObject {
    property int spacing: 10
  }
  
  property QtObject error: QtObject {
    property color color: Colors.error
  }
  property QtObject info: QtObject {
    property color color: Colors.j
    property int pointSize: Units.dp * 11
  }
}
