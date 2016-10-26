pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property int spacing: 1

  property QtObject entry: QtObject {
    property int leftMargin: 4
    property int rightMargin: 4

    property QtObject color: QtObject {
      property color hovered: Colors.s
      property color normal: Colors.i
      property color pressed: Colors.t
    }

    property QtObject text: QtObject {
      property color color: Colors.k
      property int fontSize: 8
    }
  }
}
