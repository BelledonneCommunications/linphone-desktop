pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int leftMargin: 30
  property int rightMargin: 15
  property int overrodeHeight: 55

  property QtObject message: QtObject {
    property color color: Colors.h
    property int pointSize: Units.dp * 10
  }
}
