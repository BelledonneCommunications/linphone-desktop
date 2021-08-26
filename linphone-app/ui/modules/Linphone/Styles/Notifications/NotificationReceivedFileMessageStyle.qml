pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property color color: Colors.k.color
  property int leftMargin: 25
  property int overrodeHeight: 55
  property int rightMargin: 15
  property int spacing: 10

  property QtObject fileName: QtObject {
    property color color: Colors.h.color
    property int pointSize: Units.dp * 10
  }

  property QtObject fileSize: QtObject {
    property color color: Colors.h.color
    property int pointSize: Units.dp * 9
    property int width: 100
  }
}
