pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property QtObject info: QtObject {
    property int height: 245
    property int iconSize: 150

    property QtObject description: QtObject {
      property color color: Colors.g
      property int fontSize: 10
      property int height: 40
    }

    property QtObject title: QtObject {
      property color color: Colors.g
      property int fontSize: 11
      property int height: 40
    }
  }

  property QtObject buttons: QtObject {
    property int height: 90
    property int maxWidth: 690
    property int spacing: 5
  }
}
