pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property color color: Colors.k

  property int leftMargin: 50
  property int rightMargin: 50

  property QtObject buttons: QtObject {
    property int bottomMargin: 15
    property int spacing: 20
    property int topMargin: 15
  }

  property QtObject confirmDialog: QtObject {
    property int height: 200
    property int width: 400
  }

  property QtObject description: QtObject {
    property color color: Colors.j
    property int fontSize: 11
    property int verticalMargin: 25
  }
}
