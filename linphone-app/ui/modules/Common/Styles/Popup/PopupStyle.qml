pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
  property color backgroundColor: ColorsList.add("Popup_background", "k").color

  property QtObject shadow: QtObject {
    property color color: ColorsList.add("Popup_shadow", "l").color
    property int horizontalOffset: 2
    property int radius: 10
    property int samples: 15
    property int verticalOffset: 2
  }
}
