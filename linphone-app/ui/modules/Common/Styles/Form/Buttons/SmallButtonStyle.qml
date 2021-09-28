pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property int leftPadding: 5
  property int rightPadding: 5

  property QtObject background: QtObject {
    property int height: 22
    property int radius: 20

    property QtObject color: QtObject {
      property color hovered: ColorsList.add("SmallButton_background_hovered", "c").color
      property color normal: ColorsList.add("SmallButton_background_normal", "f").color
      property color pressed: ColorsList.add("SmallButton_background_pressed", "i").color
    }
  }

  property QtObject text: QtObject {
    property color color: ColorsList.add("SmallButton_text", "q").color
    property int pointSize: Units.dp * 8
  }
}
