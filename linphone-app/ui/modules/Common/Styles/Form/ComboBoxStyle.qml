pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0
// =============================================================================

QtObject {
  property QtObject background: QtObject {
    property int height: 36
    property int iconSize: 10
    property int radius: 4
    property int width: 200

    property QtObject border: QtObject {
      property color color: ColorsList.add("ComboBox_border_normal", "c").color
      property int width: 1
    }

    property QtObject color: QtObject {
      property color normal: ColorsList.add("ComboBox_normal", "q").color
      property color readOnly: ColorsList.add("ComboBox_readonly", "e").color
    }
  }

  property QtObject contentItem: QtObject {
    property int iconSize: 20
    property int leftMargin: 10
    property int spacing: 5

    property QtObject text: QtObject {
      property color color: ColorsList.add("ComboBox_text_normal", "d").color
      property int pointSize: Units.dp * 10
    }
  }
}
