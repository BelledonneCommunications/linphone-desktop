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
    property int height: 150
    property int width: 370
  }

  property QtObject description: QtObject {
    property color color: Colors.l
    property int fontSize: 12
    property int verticalMargin: 25
  }
}
