pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property QtObject entry: QtObject {
    property int rightMargin: 10
    property int iconSize: 36

    property QtObject color: QtObject {
      property color normal: Colors.k
      property color hovered: Colors.y
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
    property int height: 40
    property int iconSize: 22
    property int leftMargin: 20
    property int rightMargin: 10

    property QtObject color: QtObject {
      property color normal: Colors.j
      property color pressed: Colors.i
    }

    property QtObject text: QtObject {
      property int fontSize: 9

      property QtObject color: QtObject {
        property color normal: Colors.k
        property color pressed: Colors.k
      }
    }
  }
}
