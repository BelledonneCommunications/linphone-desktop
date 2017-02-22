pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property QtObject tools: QtObject {
    property int width: 30

    property QtObject button: QtObject {
      property int iconSize: 16

      property QtObject color: QtObject {
        property color hovered: Colors.c
        property color normal: Colors.q
        property color pressed: Colors.c
      }
    }
  }
}
