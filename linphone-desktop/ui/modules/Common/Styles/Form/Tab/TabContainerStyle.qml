pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property color color: Colors.k
  property int bottomMargin: 30
  property int leftMargin: 30
  property int rightMargin: 40
  property int topMargin: 30

  property QtObject separator: QtObject {
    property int height: 2
    property color color: Colors.u
  }
}
