pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property QtObject entry: QtObject {
    property int height: 50
    property int iconSize: 36
    property int rightMargin: 10

    property QtObject color: QtObject {
      property color hovered: Colors.o.color
      property color normal: Colors.q.color
    }

    property QtObject indicator: QtObject {
      property color color: Colors.i.color
      property int width: 5
    }

    property QtObject separator: QtObject {
      property color color: Colors.c.color
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
      property color normal: Colors.j.color
      property color pressed: Colors.i.color
    }

    property QtObject text: QtObject {
      property int pointSize: Units.dp * 9

      property QtObject color: QtObject {
        property color normal: Colors.q.color
        property color pressed: Colors.q.color
      }
    }
  }
}
