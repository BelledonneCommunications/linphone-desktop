pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.q
  property int iconSize: 12
  property int padding: 10

  property QtObject placeholder: QtObject {
    property color color: Colors.w
    property int fontSize: 10
  }

  property QtObject text: QtObject {
    property int fontSize: 10

    property QtObject color: QtObject {
      property color focused: Colors.l
      property color normal: Colors.r
    }
  }
}
