pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color color: Colors.k

  property QtObject buttons: QtObject {
    property int bottomMargin: 15
    property int leftMargin: 50
    property int spacing: 20
    property int topMargin: 15
  }

  property QtObject confirmDialog: QtObject {
    property int height: 200
    property int width: 400
  }

  property QtObject content: QtObject {
    property int leftMargin: 25
    property int rightMargin: 25
  }

  property QtObject description: QtObject {
    property color color: Colors.j
    property int leftMargin: 50
    property int pointSize: Units.dp * 11
    property int rightMargin: 50
    property int verticalMargin: 25
  }
}
