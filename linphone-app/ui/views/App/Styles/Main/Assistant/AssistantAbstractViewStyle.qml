pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property QtObject buttons: QtObject {
    property int spacing: 10
  }

  property QtObject content: QtObject {
    property int height: 375
    property int width: 400
  }

  property QtObject info: QtObject {
    property int spacing: 20

    property QtObject description: QtObject {
      property color color: Colors.g
      property int pointSize: Units.dp * 11
    }

    property QtObject title: QtObject {
      property color color: Colors.g
      property int pointSize: Units.dp * 11
    }
  }
}
