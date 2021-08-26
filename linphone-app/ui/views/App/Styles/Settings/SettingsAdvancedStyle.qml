pragma Singleton
import QtQml 2.2

import Units 1.0
// =============================================================================

QtObject {
  property QtObject buttons: QtObject {
    property int spacing: 10
  }
  
  property QtObject error: QtObject {
    property color color: Colors.error.color
  }
  property QtObject info: QtObject {
    property color color: Colors.j.color
    property int pointSize: Units.dp * 11
  }
  property QtObject lists: QtObject {
    property int spacing: 20
    property real iconScale : 0.8
    property int margin: 10
  }
}
