pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int spacing: 1
  property color backgroundColor: Colors.x

  property QtObject entry: QtObject {
    property int iconSize: 24
    property int leftMargin: 20
    property int rightMargin: 20
    property int spacing: 18

    property QtObject color: QtObject {
      property color hovered: Colors.h
      property color normal: Colors.g
      property color pressed: Colors.i
      property color selected: Colors.j
    }

    property QtObject indicator: QtObject {
      property color color: Colors.i
      property int width: 5
    }

    property QtObject text: QtObject {
      property int pointSize: Units.dp * 11

      property QtObject color: QtObject {
        property color normal: Colors.k50
        property color selected: Colors.k
      }
    }
  }
}
