pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int spacing: 8

  property QtObject backgroundColor: QtObject {
    property color disabled: Colors.i30
    property color hovered: Colors.b
    property color normal: Colors.i
    property color pressed: Colors.m
    property color selected: Colors.k
  }

  property QtObject icon: QtObject {
    property int size: 20
  }

  property QtObject text: QtObject {
    property int pointSize: Units.dp * 9
    property int height: 40
    property int leftPadding: 10
    property int rightPadding: 10

    property QtObject color: QtObject {
      property color disabled: Colors.q
      property color hovered: Colors.q
      property color normal: Colors.q
      property color pressed: Colors.q
      property color selected: Colors.i
    }
  }
}
