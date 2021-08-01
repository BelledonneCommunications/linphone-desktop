pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property int spacing: 1
  property color backgroundColor: Colors.n.color

  property QtObject entry: QtObject {
    property int iconSize: 24
    property int leftMargin: 20
    property int rightMargin: 20
    property int spacing: 18

    property QtObject color: QtObject {
      property color hovered: Colors.h.color
      property color normal: Colors.g.color
      property color pressed: Colors.i.color
      property color selected: Colors.j.color
    }

    property QtObject indicator: QtObject {
      property color color: Colors.i.color
      property int width: 5
    }

    property QtObject text: QtObject {
      property int pointSize: Units.dp * 10

      property QtObject color: QtObject {
        property color normal: Colors.q.color	//q50
        property color selected: Colors.q.color
      }
    }
  }
}
