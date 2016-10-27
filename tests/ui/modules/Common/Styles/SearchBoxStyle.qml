pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property color shadowColor: Colors.f

  property Rectangle searchFieldBackground: Rectangle {
    implicitHeight: 40

    border {
      color: '#CBCBCB'
      width: 1
    }

    radius: 4
  }

  property QtObject text: QtObject {
    property color color: Colors.d
    property int fontSize: 11
  }
}
