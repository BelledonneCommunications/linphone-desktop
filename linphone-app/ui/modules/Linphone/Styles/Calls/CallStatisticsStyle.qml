pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property color color: Colors.e.color
  property int height: 280
  property int leftMargin: 12
  property int rightMargin: 12
  property int spacing: 8
  property int topMargin: 10

  property QtObject title: QtObject {
    property color color: Colors.d.color
    property int bottomMargin: 20
    property int pointSize: Units.dp * 16
  }

  property QtObject key: QtObject {
    property color color: Colors.d.color
    property int pointSize: Units.dp * 10
    property int width: 200
  }

  property QtObject value: QtObject {
    property color color: Colors.d.color
    property int pointSize: Units.dp * 10
  }
}
