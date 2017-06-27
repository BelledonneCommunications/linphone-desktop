pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color color: Colors.k
  property int bottomMargin: 15
  property int leftMargin: 15
  property int overrodeHeight: 55
  property int rightMargin: 15
  property int spacing: 0

  property QtObject messageContainer: QtObject {
    property color color: Colors.m
    property int radius: 6
    property int margins: 10

    property QtObject text: QtObject {
      property color color: Colors.l
      property int pointSize: Units.dp * 9
    }
  }
}
