pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property QtObject background: QtObject {
    property color color: Colors.k
    property int height: 36
    property int radius: 4

    property QtObject border: QtObject {
      property color color: '#CBCBCB'
      property int width: 1
    }
  }

  property QtObject text: QtObject {
    property color color: Colors.d
    property int fontSize: 10
  }
}
