pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.g20

  property QtObject contentItem: QtObject {
    property int implicitHeight: 8
    property int implicitWidth: 8
    property int radius: 10
  }

  property QtObject color: QtObject {
    property color hovered: Colors.h
    property color normal: Colors.g20
    property color pressed: Colors.b
  }
}
