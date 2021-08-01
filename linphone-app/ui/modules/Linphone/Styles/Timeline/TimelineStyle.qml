pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property color color: Colors.q.color

  property QtObject contact: QtObject {
    property int height: 60

    property QtObject backgroundColor: QtObject {
      property color a: Colors.g10.color
      property color b: Colors.a.color
      property color selected: Colors.i.color
    }

    property QtObject sipAddress: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.n.color
        property color selected: Colors.q.color
      }
    }

    property QtObject username: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.j.color
        property color selected: Colors.q.color
      }
    }
  }

  property QtObject legend: QtObject {
    property QtObject backgroundColor: QtObject {
      property color normal: Colors.f.color
      property color hovered: Colors.c.color
    }
    property color color: Colors.d.color
    property int pointSize: Units.dp * 10
    property int height: 30
    property int iconSize: 14
    property int leftMargin: 17
    property int rightMargin: 17
    property int spacing: 8
  }
}
