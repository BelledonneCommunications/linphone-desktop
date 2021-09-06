pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property int spacing: 1
  property color backgroundColor: ColorsList.add("ApplicationMenu_background", "n").color

  property QtObject entry: QtObject {
    property int iconSize: 24
    property int leftMargin: 20
    property int rightMargin: 20
    property int spacing: 18

    property QtObject color: QtObject {
      property color hovered: ColorsList.add("ApplicationMenu_entry_hovered", "h").color
      property color normal: ColorsList.add("ApplicationMenu_entry_normal", "g").color
      property color pressed: ColorsList.add("ApplicationMenu_entry_pressed", "i").color
      property color selected: ColorsList.add("ApplicationMenu_entry_selected", "j").color
    }

    property QtObject indicator: QtObject {
      property color color: ColorsList.add("ApplicationMenu_entry_indicator", "i").color
      property int width: 5
    }

    property QtObject text: QtObject {
      property int pointSize: Units.dp * 10

      property QtObject color: QtObject {
        property color normal: ColorsList.add("ApplicationMenu_entry_text_normal", "q").color
        property color selected: ColorsList.add("ApplicationMenu_entry_text_selected", "q").color
      }
    }
  }
}
