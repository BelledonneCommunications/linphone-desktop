pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property color backgroundColor: ColorsList.add("Avatar_background", "d").color

  property QtObject initials: QtObject {
    property color color: ColorsList.add("Avatar_initials", "q").color
    property int pointSize: Units.dp * 10
    property int ratio: 30
  }
}
