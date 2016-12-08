pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property color backgroundColor: Colors.q
  property int padding: 10

  property QtObject textColor: QtObject {
    property color focused: Colors.l
    property color normal: Colors.r
  }
}
