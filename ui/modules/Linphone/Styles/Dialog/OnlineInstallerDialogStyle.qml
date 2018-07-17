pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int height: 200
  property int width: 400

  property QtObject column: QtObject {
    property int spacing: 6

    property QtObject bar: QtObject {
      property int height: 20
      property int radius: 6

      property QtObject background: QtObject {
        property color color: Colors.f
      }

      property QtObject contentItem: QtObject {
        property QtObject color: QtObject {
          property color failed: Colors.error
          property color normal: Colors.p
      }
    }
  }

    property QtObject text: QtObject {
      property color color: Colors.d
      property int pointSize: Units.dp * 11
    }
  }
}
