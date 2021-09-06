pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property QtObject background: QtObject {
    property int height: 36
    property int width: 200

    property int radius: 4

    property QtObject border: QtObject {
      property color color: ColorsList.add("TextAreaField_background_border", "c").color
      property int width: 1
    }

    property QtObject color: QtObject {
      property color normal: ColorsList.add("TextAreaField_background_normal", "q").color
      property color readOnly: ColorsList.add("TextAreaField_background_reeadOnly", "e").color
    }
  }

  property QtObject text: QtObject {
    property color color: ColorsList.add("TextAreaField_text", "d").color
    property int pointSize: Units.dp * 10
    property int padding: 8
  }
}
