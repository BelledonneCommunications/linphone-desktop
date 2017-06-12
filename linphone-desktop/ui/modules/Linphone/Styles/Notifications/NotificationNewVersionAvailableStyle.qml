pragma Singleton
import QtQuick 2.7

import Common 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color color: Colors.k
  property int height: 55
  property int iconSize: 40
  property int leftMargin: 30
  property int rightMargin: 15
  property int width: 300

  property QtObject message: QtObject {
    property color color: Colors.h
    property int pointSize: Units.dp * 10
  }
}
