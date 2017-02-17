pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int height: 316
  property int leftMargin: 35
  property int rightMargin: 35
  property int spacing: 15
  property int width: 480

  property QtObject input: QtObject {
    property int spacing: 6

    property QtObject legend: QtObject {
      property color color: Colors.j
      property int fontSize: 10
    }
  }
}
