pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
  property int buttonsSpacing: 8

  property QtObject button: QtObject {
    property QtObject color: QtObject {
      property color hovered: ColorsList.add("Exclusive_button_hovered", "n").color
      property color normal: ColorsList.add("Exclusive_button_normal", "x").color
      property color pressed: ColorsList.add("Exclusive_button_pressed", "i").color
      property color selected: ColorsList.add("Exclusive_button_selected", "g").color
    }
  }
}
