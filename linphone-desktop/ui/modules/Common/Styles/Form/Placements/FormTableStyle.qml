pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int spacing: 10

  property QtObject entry: QtObject {
    property int height: 36
    property int width: 200
    property int maxWidth: 400

    property QtObject text: QtObject {
      property color color: Colors.j
      property int pointSize: Units.dp * 10
    }
  }
}
