pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property QtObject contact: QtObject {
    property color colorA: Colors.g10
    property color colorB: Colors.a
    property int height: 60
  }

  property QtObject legend: QtObject {
    property color backgroundColor: Colors.u
    property color color: Colors.k
    property int fontSize: 12
    property int height: 30
    property int iconSize: 10
    property int leftMargin: 17
    property int rightMargin: 17
    property int spacing: 8
  }
}
