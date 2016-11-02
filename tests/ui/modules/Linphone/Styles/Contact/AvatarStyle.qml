pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property QtObject initials: QtObject {
    property color color: Colors.k
    property int fontSize: 10
  }

  property QtObject mask: QtObject {
    property color color: Colors.r
    property int radius: 500
  }
}
