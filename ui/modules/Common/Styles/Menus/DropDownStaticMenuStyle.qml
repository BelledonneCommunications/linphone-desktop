pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int spacing: 1

  property QtObject entry: QtObject {
    property int leftMargin: 18
    property int rightMargin: 8

    property QtObject color: QtObject {
      property color hovered: Colors.j
      property color normal: Colors.g
      property color pressed: Colors.i
    }

    property QtObject text: QtObject {
      property color color: Colors.k
      property int pointSize: Units.dp * 9
    }
  }
}
