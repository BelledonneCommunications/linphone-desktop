pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
  property int transitionDuration: 200

  property QtObject handle: QtObject {
    property int width: 5

    property QtObject color: QtObject {
      property color hovered: ColorsList.add("Paned_hovered", "h").color
      property color normal: ColorsList.add("Paned_normal", "c").color
      property color pressed: ColorsList.add("Paned_pressed", "d").color
    }
  }
}
