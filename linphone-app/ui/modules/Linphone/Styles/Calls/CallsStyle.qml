pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
  property QtObject entry: QtObject {
    property int iconActionSize: 35
    property int iconMenuSize: 17
    property int height: 30
    property int width: 200

    property QtObject color: QtObject {
      property color normal: ColorsList.add("Calls_entry_normal", "e").color
      property color selected: ColorsList.add("Calls_entry_selected", "j").color
    }

    property QtObject endCallAnimation: QtObject {
      property color blinkColor: ColorsList.add("Calls_entry_end_blink", "i").color
      property int duration: 300
      property int loops: 3
    }

    property QtObject sipAddressColor: QtObject {
      property color normal: ColorsList.add("Calls_entry_sipAddress_normal", "n").color
      property color selected: ColorsList.add("Calls_entry_sipAddress_selected", "q").color
    }

    property QtObject usernameColor: QtObject {
      property color normal: ColorsList.add("Calls_entry_username_normal", "j").color
      property color selected: ColorsList.add("Calls_entry_username_selected", "q").color
    }
  }
}
