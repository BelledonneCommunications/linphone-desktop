pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property color backgroundColor: ColorsList.add("TabTransparentTextInput_background", "f").color
  property int iconSize: 12
  property int padding: 10

  property QtObject placeholder: QtObject {
    property color color: ColorsList.add("TabTransparentTextInput_palceholder", "n").color
    property int pointSize: Units.dp * 10
  }

  property QtObject text: QtObject {
    property int pointSize: Units.dp * 10

    property QtObject color: QtObject {
      property color focused: ColorsList.add("TabTransparentTextInput_text_focused", "l").color
      property color normal: ColorsList.add("TabTransparentTextInput_text_normal", "d").color
    }
  }
}
