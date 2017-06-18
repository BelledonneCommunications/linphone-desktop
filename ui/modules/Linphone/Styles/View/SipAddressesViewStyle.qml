pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property QtObject entry: QtObject {
    property int height: 50
    property int iconSize: 36
    property int rightMargin: 10

    property QtObject color: QtObject {
      property color hovered: Colors.y
      property color normal: Colors.k
    }

    property QtObject indicator: QtObject {
      property color color: Colors.i
      property int width: 5
    }

    property QtObject separator: QtObject {
      property color color: Colors.c
      property int height: 1
    }
  }

  property QtObject header: QtObject {
    property int iconSize: 22
    property int leftMargin: 20
    property int rightMargin: 10

    property QtObject button: QtObject {
      property int height: 40
    }

    property QtObject color: QtObject {
      property color normal: Colors.j
      property color pressed: Colors.i
    }

    property QtObject text: QtObject {
      property int pointSize: Units.dp * 9

      property QtObject color: QtObject {
        property color normal: Colors.k
        property color pressed: Colors.k
      }
    }
  }
}
