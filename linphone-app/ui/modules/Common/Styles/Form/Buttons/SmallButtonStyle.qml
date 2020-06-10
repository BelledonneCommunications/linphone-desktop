pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int leftPadding: 5
  property int rightPadding: 5

  property QtObject background: QtObject {
    property int height: 22
    property int radius: 10

    property QtObject color: QtObject {
      property color hovered: Colors.c
      property color normal: Colors.f
      property color pressed: Colors.i
    }
  }

  property QtObject text: QtObject {
    property color color: Colors.q
    property int pointSize: Units.dp * 8
  }
}
