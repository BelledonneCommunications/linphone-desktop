pragma Singleton
import QtQml 2.2

import Units 1.0

import ColorsList 1.0

// =============================================================================

QtObject {
  property QtObject iconSize: QtObject {
    property int amount: 12
    property int message: 18
  }

  property QtObject text: QtObject {
    property color color: ColorsList.add("MessageCounter_text", "q").color
    property int pointSize: Units.dp * 6
  }
}
