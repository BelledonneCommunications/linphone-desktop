pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.k

  property QtObject fileChooserButton: QtObject {
    property int margins: 6
    property int size: 20
  }

  property QtObject hoverContent: QtObject {
    property color backgroundColor: Colors.k

    property QtObject text: QtObject {
      property color color: Colors.i
      property int pointSize: Units.dp * 11
    }
  }

  property QtObject text: QtObject {
    property color color: Colors.d
    property int pointSize: Units.dp * 10
  }
}
