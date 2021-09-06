pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
  property int height: 40
  property int width: 5

  property QtObject high: QtObject {
    property QtObject background: QtObject {
      property QtObject color: QtObject {
        property color disabled:  ColorsList.add("VuMeter_background_disabled", "o").color
        property color enabled: ColorsList.add("VuMeter_background_enabled", "n").color
      }
    }

    property QtObject contentItem: QtObject {
      property color color: ColorsList.add("VuMeter_contentItem", "b").color
    }
  }

  property QtObject low: QtObject {
    property QtObject background: QtObject {
      property QtObject color: QtObject {
        property color disabled: ColorsList.add("VuMeter_low_background_disabled", "o").color
        property color enabled: ColorsList.add("VuMeter_low_background_enabled", "n").color
      }
    }

    property QtObject contentItem: QtObject {
      property color color: ColorsList.add("VuMeter_low_contentItem", "j").color
    }
  }
}
