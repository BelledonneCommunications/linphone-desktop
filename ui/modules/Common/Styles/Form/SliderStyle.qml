pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property QtObject background: QtObject {
    property color color: Colors.c
    property int height: 4
    property int radius: 2
    property int width: 200

    property QtObject content: QtObject {
      property color color: Colors.m
      property int radius: 2
    }
  }

  property QtObject handle: QtObject {
    property int height: 16
    property int radius: 13
    property int width: 16

    property QtObject border: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.c
        property color pressed: Colors.c
      }
    }

    property QtObject color: QtObject {
      property color normal: Colors.e
      property color pressed: Colors.f
    }
  }
}
