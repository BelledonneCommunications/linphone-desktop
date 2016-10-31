pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property color backgroundColor: Colors.g20

  property Rectangle contentItem: Rectangle {
    implicitHeight: 100
    implicitWidth: 8
    radius: 10
  }

  property QtObject color: QtObject {
    property color hovered: Colors.h
    property color normal: Colors.g20
    property color pressed: Colors.b
  }
}
