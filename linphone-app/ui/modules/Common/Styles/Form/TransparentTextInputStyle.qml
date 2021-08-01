pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.f.color
  property int iconSize: 12
  property int padding: 10

  property QtObject placeholder: QtObject {
    property color color: Colors.n.color
    property int pointSize: Units.dp * 10
  }

  property QtObject text: QtObject {
    property int pointSize: Units.dp * 10

    property QtObject color: QtObject {
      property color focused: Colors.l.color
      property color normal: Colors.d.color
    }
  }
}
