pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property int spacing: 8

  property QtObject backgroundColor: QtObject {
    property color disabled: Colors.i30.color
    property color hovered: Colors.b.color
    property color normal: Colors.i.color
    property color pressed: Colors.m.color
    property color selected: Colors.k.color
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
      property color disabled: Colors.q.color
      property color hovered: Colors.q.color
      property color normal: Colors.q.color
      property color pressed: Colors.q.color
      property color selected: Colors.i.color
    }
  }
}
