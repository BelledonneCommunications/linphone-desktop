pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property QtObject fileChooserButton: QtObject {
    property int margins: 6
    property int width: 40
  }

  property QtObject hoverContent: QtObject {
    property color backgroundColor: Colors.k

    property QtObject text: QtObject {
      property color color: Colors.i
      property int fontSize: 11
    }
  }
}
