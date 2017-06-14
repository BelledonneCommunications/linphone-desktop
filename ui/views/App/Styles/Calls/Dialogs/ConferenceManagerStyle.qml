pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int height: 420
  property int leftMargin: 35
  property int rightMargin: 35
  property int width: 740

  property QtObject columns: QtObject {
    property QtObject selector: QtObject {
      property int spacing: 10
    }

    property QtObject separator: QtObject {
      property color color: Colors.c
      property int width: 1
    }
  }
}
