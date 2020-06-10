pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property QtObject background: QtObject {
    property int height: 36
    property int iconSize: 10
    property int radius: 4
    property int width: 200

    property QtObject border: QtObject {
      property color color: Colors.c
      property int width: 1
    }

    property QtObject color: QtObject {
      property color normal: Colors.q
      property color readOnly: Colors.e
    }
  }

  property QtObject contentItem: QtObject {
    property int iconSize: 20
    property int leftMargin: 10
    property int spacing: 5

    property QtObject text: QtObject {
      property color color: Colors.d
      property int pointSize: Units.dp * 10
    }
  }
}
