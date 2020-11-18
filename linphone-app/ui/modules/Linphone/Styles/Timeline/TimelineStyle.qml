pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color color: Colors.q

  property QtObject contact: QtObject {
    property int height: 60

    property QtObject backgroundColor: QtObject {
      property color a: Colors.g10
      property color b: Colors.a
      property color selected: Colors.i
    }

    property QtObject sipAddress: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.n
        property color selected: Colors.q
      }
    }

    property QtObject username: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.j
        property color selected: Colors.q
      }
    }
  }

  property QtObject legend: QtObject {
    property QtObject backgroundColor: QtObject {
      property color normal: Colors.f
      property color hovered: Colors.c
    }
    property color color: Colors.d
    property int pointSize: Units.dp * 11
    property int height: 30
    property int iconSize: 14
    property int leftMargin: 17
    property int rightMargin: 17
    property int spacing: 8
  }
}
