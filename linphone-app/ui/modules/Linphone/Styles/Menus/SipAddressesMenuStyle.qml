pragma Singleton
import QtQml 2.2

import Units 1.0

import ColorsList 1.0

// =============================================================================

QtObject {
  property int spacing: 1
  property int maxHeight: 164

  property QtObject entry: QtObject {
    property int leftMargin: 18
    property int rightMargin: 8
    property int height: 40
    property int width: 300

    property QtObject color: QtObject {
      property color hovered: ColorsList.add("SipAddressView_entry_hovered", "j").color
      property color normal: ColorsList.add("SipAddressView_entry_normal", "g").color
      property color pressed: ColorsList.add("SipAddressView_entry_pressed", "i").color
    }

    property QtObject text: QtObject {
      property color color: ColorsList.add("SipAddressView_entry_text", "q").color
      property int pointSize: Units.dp * 10
    }
  }
}
