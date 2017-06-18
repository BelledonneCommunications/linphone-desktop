pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property QtObject animation: QtObject {
    property int duration: 200
  }

  property QtObject indicator: QtObject {
    property int height: 18
    property int radius: 10
    property int width: 48
    property QtObject border: QtObject {
      property QtObject color: QtObject {
        property color checked: Colors.i
        property color disabled: Colors.c
        property color normal: Colors.c
      }
    }

    property QtObject color: QtObject {
      property color checked: Colors.i
      property color disabled: Colors.e
      property color normal: Colors.k
    }
  }

  property QtObject sphere: QtObject {
    property int size: 22

    property QtObject border: QtObject {
      property QtObject color: QtObject {
        property color checked: Colors.i
        property color disabled: Colors.c
        property color normal: Colors.w
        property color pressed: Colors.w
      }
    }

    property QtObject color: QtObject {
      property color disabled: Colors.e
      property color pressed: Colors.c
      property color normal: Colors.k
    }
  }
}
