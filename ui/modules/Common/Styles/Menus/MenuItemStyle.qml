pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int leftPadding: 5
  property int rightPadding: 5

  property QtObject background: QtObject {
    property int height: 30

    property QtObject color: QtObject {
      property color hovered: Colors.y
      property color normal: Colors.k
      property color pressed: Colors.y
    }
  }

  property QtObject text: QtObject {
    property int pointSize: Units.dp * 10

    property QtObject color: QtObject {
      property color enabled: Colors.j
      property color disabled: Colors.l50
    }
  }
}
