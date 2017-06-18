pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property QtObject background: QtObject {
    property int height: 36
    property int width: 200

    property int radius: 4

    property QtObject border: QtObject {
      property color color: Colors.c
      property int width: 1
    }

    property QtObject color: QtObject {
      property color normal: Colors.k
      property color readOnly: Colors.e
    }
  }

  property QtObject text: QtObject {
    property color color: Colors.d
    property int pointSize: Units.dp * 10
    property int padding: 8
  }
}
