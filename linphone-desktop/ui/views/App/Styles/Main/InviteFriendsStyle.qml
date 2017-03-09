pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property color color: Colors.k
  property int width: 400

  property QtObject message: QtObject {
    property int height: 140
  }

  property QtObject buttons: QtObject {
    property int bottomMargin: 35
    property int spacing: 10
  }
}
