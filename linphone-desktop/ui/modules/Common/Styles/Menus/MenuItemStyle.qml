pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int leftPadding: 5
  property int rightPadding: 5

  property QtObject background: QtObject {
    property int height: 30

    property QtObject color: QtObject {
      property color hovered: Colors.y
      property color normal: Colors.k
      property color pressed: Colors.y
    }
  }

  property QtObject text: QtObject {
    property color color: Colors.j
    property int fontSize: 10
  }
}
