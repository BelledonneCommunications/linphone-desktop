pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property color shadowColor: Colors.f

  property Rectangle searchFieldBackground: Rectangle {
    implicitHeight: 30
  }
}
