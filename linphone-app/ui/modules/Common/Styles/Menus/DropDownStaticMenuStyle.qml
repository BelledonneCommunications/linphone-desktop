pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property int spacing: 1

  property QtObject entry: QtObject {
    property int leftMargin: 18
    property int rightMargin: 8

    property QtObject color: QtObject {
      property color hovered: ColorsList.add("DropDownMenu_entry_hovered", "j").color
      property color normal: ColorsList.add("DropDownMenu_entry_normal", "g").color
      property color pressed: ColorsList.add("DropDownMenu_entry_pressed", "i").color
    }

    property QtObject text: QtObject {
      property color color: ColorsList.add("DropDownMenu_entry_text", "q").color
      property int pointSize: Units.dp * 9
    }
  }
}
