pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
  property QtObject background: QtObject {
    property color color: ColorsList.add("Slider_background", "c").color
    property int height: 4
    property int radius: 2
    property int width: 200

    property QtObject content: QtObject {
      property color color: ColorsList.add("Slider_content", "m").color
      property int radius: 2
    }
  }

  property QtObject handle: QtObject {
    property int height: 16
    property int radius: 13
    property int width: 16

    property QtObject border: QtObject {
      property QtObject color: QtObject {
        property color normal: ColorsList.add("Slider_handle_border_normal", "c").color
        property color pressed: ColorsList.add("Slider_handle_border_pressed", "c").color
      }
    }

    property QtObject color: QtObject {
      property color normal: ColorsList.add("Slider_handle_normal", "e").color
      property color pressed: ColorsList.add("Slider_handle_pressed", "f").color
    }
  }
}
