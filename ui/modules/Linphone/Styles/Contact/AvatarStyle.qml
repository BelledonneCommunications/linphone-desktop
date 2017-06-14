pragma Singleton
import QtQuick 2.7

import Common 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.r

  property QtObject initials: QtObject {
    property color color: Colors.k
    property int pointSize: Units.dp * 10
    property int ratio: 30
  }
}
