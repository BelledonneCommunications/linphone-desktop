pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int spacing: 20

  property QtObject buttons: QtObject {
    property int spacing: 10
  }

  property QtObject content: QtObject {
    property int width: 340
  }

  property QtObject info: QtObject {
    property int spacing: 20

    property QtObject description: QtObject {
      property color color: Colors.g
      property int fontSize: 10
    }

    property QtObject title: QtObject {
      property color color: Colors.g
      property int fontSize: 11
    }
  }
}
