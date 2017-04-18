pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int columnSpacing: 0
  property int height: 180
  property int rowSpacing: 0
  property int width: 150
  property color color: Colors.k

  property QtObject button: QtObject {
    property QtObject color: QtObject {
      property color normal: Colors.k
      property color pressed: Colors.i
    }

    property QtObject text: QtObject {
      property color color: Colors.d
      property int fontSize: 10
    }
  }
}
