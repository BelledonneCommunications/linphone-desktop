pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property QtObject entry: QtObject {
    property int iconActionSize: 35
    property int iconMenuSize: 17
    property int height: 30
    property int width: 200

    property QtObject color: QtObject {
      property color normal: Colors.e
      property color selected: Colors.j
    }

    property QtObject endCallAnimation: QtObject {
      property color blinkColor: Colors.i
      property int duration: 300
      property int loops: 3
    }

    property QtObject sipAddressColor: QtObject {
      property color normal: Colors.w
      property color selected: Colors.k
    }

    property QtObject usernameColor: QtObject {
      property color normal: Colors.j
      property color selected: Colors.k
    }
  }
}
