pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

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

    property QtObject line: QtObject {
      property color color: Colors.l50
      property int bottomMargin: 4
      property int height: 2
      property int leftMargin: 8
      property int rightMargin: 8
      property int topMargin: 0
    }

    property QtObject text: QtObject {
      property color color: Colors.d
      property int pointSize: Units.dp * 11
    }
  }
}
