pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property QtObject text: QtObject {
    property color color: Colors.j
    property int fontSize: 10
  }
}
