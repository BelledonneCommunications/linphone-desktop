pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property int spacing: 1

  property QtObject entry: QtObject {
    property int leftMargin: 4
    property int rightMargin: 4

    property color color: Colors.i

    property QtObject text: QtObject {
      property color color: Colors.k

      property int fontSize: 8
    }
  }
}
