pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property int minimumHeight: 480
  property int minimumWidth: 960

  property QtObject call: QtObject {
    property int minimumWidth: 395
  }

  property QtObject callsList: QtObject {
    property color color: Colors.k
    property int defaultWidth: 250
    property int maximumWidth: 250
    property int minimumWidth: 110

    property QtObject header: QtObject {
      property color color1: Colors.k
      property color color2: Colors.v
      property int height: 60
      property int iconSize: 40
      property int leftMargin: 10
    }
  }

  property QtObject chat: QtObject {
    property int minimumWidth: 300
  }
}
