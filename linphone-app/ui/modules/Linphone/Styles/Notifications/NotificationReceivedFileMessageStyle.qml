pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color color: Colors.k
  property int leftMargin: 25
  property int overrodeHeight: 55
  property int rightMargin: 15
  property int spacing: 10

  property QtObject fileName: QtObject {
    property color color: Colors.h
    property int pointSize: Units.dp * 10
  }

  property QtObject fileSize: QtObject {
    property color color: Colors.h
    property int pointSize: Units.dp * 9
    property int width: 100
  }
}
