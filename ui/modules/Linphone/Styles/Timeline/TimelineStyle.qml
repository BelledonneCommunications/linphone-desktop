pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color color: Colors.k

  property QtObject contact: QtObject {
    property int height: 60

    property QtObject backgroundColor: QtObject {
      property color a: Colors.g10
      property color b: Colors.a
      property color selected: Colors.i
    }

    property QtObject sipAddress: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.w
        property color selected: Colors.k
      }
    }

    property QtObject username: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.j
        property color selected: Colors.k
      }
    }
  }

  property QtObject legend: QtObject {
    property color backgroundColor: Colors.u
    property color color: Colors.k
    property int pointSize: Units.dp * 11
    property int height: 30
    property int iconSize: 10
    property int leftMargin: 17
    property int rightMargin: 17
    property int spacing: 8
  }
}
