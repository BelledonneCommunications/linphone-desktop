pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property QtObject background: QtObject {
    property int height: 36
    property int iconSize: 10
    property int radius: 4
    property int width: 200

    property QtObject border: QtObject {
      property color color: Colors.c.color
      property int width: 1
    }

    property QtObject color: QtObject {
      property color normal: Colors.q.color
      property color readOnly: Colors.e.color
    }
  }

  property QtObject contentItem: QtObject {
    property int iconSize: 20
    property int leftMargin: 10
    property int spacing: 5

    property QtObject text: QtObject {
      property color color: Colors.d.color
      property int pointSize: Units.dp * 10
    }
  }
}
