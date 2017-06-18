pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int spacing: 10

  property QtObject header: QtObject {
    property int bottomMargin: 5
    property int spacing: 5

    property QtObject separator: QtObject {
      property color color: Colors.i
      property int height: 2
    }

    property QtObject title: QtObject {
      property color color: Colors.i
      property int pointSize: Units.dp * 12
    }
  }
}
