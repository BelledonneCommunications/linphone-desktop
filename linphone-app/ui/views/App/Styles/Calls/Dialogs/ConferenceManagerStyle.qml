pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property int height: 420
  property int width: 740

  property QtObject columns: QtObject {
    property QtObject selector: QtObject {
      property int spacing: 10
    }

    property QtObject separator: QtObject {
      property color color: Colors.c
      property int leftMargin: 25
      property int rightMargin: 25
      property int width: 1
    }
  }
}
