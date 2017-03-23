pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property color color: Colors.e
  property int height: 60
  property int leftMargin: 12
  property int rightMargin: 12
  property int width: 240

  property QtObject title: QtObject {
    property color color: Colors.l
    property int fontSize: 16
  }

  property QtObject key: QtObject {
    property int width: 200
    property color color: Colors.l
    property int fontSize: 10
  }

  property QtObject value: QtObject {
    property color color: Colors.l
    property int fontSize: 10
  }
}
