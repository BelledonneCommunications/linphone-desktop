pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property QtObject backgroundColor: QtObject {
    property color hovered: Colors.s
    property color normal: Colors.i
    property color pressed: Colors.t
  }

  property QtObject textColor: QtObject {
    property color hovered: Colors.k
    property color normal: Colors.k
    property color pressed: Colors.k
  }
}
