pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property color backgroundColor: Colors.k

  property QtObject animation: QtObject {
    property int openingDuration: 250
    property int closingDuration: 250
  }

  property QtObject shadow: QtObject {
    property color color: Colors.l
    property int horizontalOffset: 2
    property int radius: 10
    property int samples: 15
    property int verticalOffset: 2
  }
}
