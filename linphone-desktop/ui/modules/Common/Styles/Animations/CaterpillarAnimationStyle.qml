pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int nSpheres: 3
  property int spacing: 6

  property QtObject animation: QtObject {
    property int duration: 200
    property int space: 10
  }

  property QtObject sphere: QtObject {
    property color color: Colors.x
    property int size: 10
  }
}
