pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int spacing: 5

  property QtObject content: QtObject {
    property int maxWidth: 400
  }

  property QtObject error: QtObject {
    property color color: Colors.error
    property int fontSize: 10
    property int height: 11
  }

  property QtObject legend: QtObject {
    property color color: Colors.j
    property int fontSize: 10
  }
}
