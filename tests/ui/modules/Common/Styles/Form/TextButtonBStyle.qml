pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property QtObject backgroundColor: QtObject {
    property color hovered: Colors.p
    property color normal: Colors.m
    property color pressed: Colors.i
  }

  property QtObject textColor: QtObject {
    property color hovered: Colors.d
    property color normal: Colors.d
    property color pressed: Colors.k
  }
}
