pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property QtObject tools: QtObject {
    property int width: 20

    property QtObject button: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.q
        property color pressed: Colors.c
      }

      property QtObject text: QtObject {
        property color color: Colors.d
        property int fontSize: 9
      }
    }
  }
}
