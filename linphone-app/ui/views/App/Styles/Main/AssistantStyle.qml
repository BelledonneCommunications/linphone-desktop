pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property color color: Colors.k
  property int bottomMargin: 35
  property int leftMargin: 90
  property int rightMargin: 90
  property int topMargin: 50

  property QtObject stackAnimation: QtObject {
    property int duration: 400
  }
}
