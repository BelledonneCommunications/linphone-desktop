pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property int spacing: 8

  property QtObject backgroundColor: QtObject {
    property color disabled: ColorsList.add("TabButton_background_disabled", "i30").color
    property color hovered: ColorsList.add("TabButton_background_hovered", "b").color
    property color normal: ColorsList.add("TabButton_background_normal", "i").color
    property color pressed: ColorsList.add("TabButton_background_pressed", "m").color
    property color selected: ColorsList.add("TabButton_background_selected", "k").color
  }

  property QtObject icon: QtObject {
    property int size: 20
  }

  property QtObject text: QtObject {
    property int pointSize: Units.dp * 9
    property int height: 40
    property int leftPadding: 10
    property int rightPadding: 10

    property QtObject color: QtObject {
      property color disabled: ColorsList.add("TabButton_text_disabled", "q").color
      property color hovered: ColorsList.add("TabButton_text_hovered", "q").color
      property color normal: ColorsList.add("TabButton_text_normal", "q").color
      property color pressed: ColorsList.add("TabButton_text_pressed", "q").color
      property color selected: ColorsList.add("TabButton_text_selected", "i").color
    }
  }
}
