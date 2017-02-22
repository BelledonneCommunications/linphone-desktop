pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property QtObject background: QtObject {
    property color color: Colors.k
    property int height: 36
    property int iconSize: 10
    property int radius: 4
    property int width: 400

    property QtObject border: QtObject {
      property color color: Colors.c
      property int width: 1
    }
  }

  property QtObject delegate: QtObject {
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
}
