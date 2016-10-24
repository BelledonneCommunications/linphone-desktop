pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property int transitionDuration: 200

  property QtObject handle: QtObject {
    property int width: 5

    property QtObject color: QtObject {
      property color hovered: Colors.h
      property color normal: Colors.c
      property color pressed: Colors.b
    }
  }
}
