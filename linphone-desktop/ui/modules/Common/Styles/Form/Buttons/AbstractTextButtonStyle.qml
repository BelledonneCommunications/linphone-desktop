pragma Singleton
import QtQuick 2.7

import Units 1.0

// =============================================================================

QtObject {
  property QtObject background: QtObject {
    property int height: 30
    property int radius: 4
    property int width: 160
  }

  property QtObject text: QtObject {
    property int pointSize: Units.dp * 8
  }
}
