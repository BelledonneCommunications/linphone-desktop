pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property color color: Colors.k
  property int bottomMargin: 35
  property int leftMargin: 90
  property int rightMargin: 90
  property int topMargin: 35
  property int height: 480
  property int width: 700

  property QtObject stackAnimation: QtObject {
    property int duration: 400
  }
}
