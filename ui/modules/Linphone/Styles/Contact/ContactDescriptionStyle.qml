pragma Singleton
import QtQuick 2.7

import Common 1.0
import Units 1.0

// =============================================================================

QtObject {
  property QtObject sipAddress: QtObject {
    property color color: Colors.w
    property int pointSize: Units.dp * 10
  }

  property QtObject username: QtObject {
    property color color: Colors.j
    property int pointSize: Units.dp * 11
  }
}
