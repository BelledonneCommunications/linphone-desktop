pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property QtObject backgroundColor: QtObject {
    property color focused: Colors.q
    property color normal: Colors.a
  }

  property QtObject textColor: QtObject {
    property color focused:  Colors.l
    property color normal: Colors.r
  }
}
