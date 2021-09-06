pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property color color: ColorsList.add("Timeline_background", "q").color

  property QtObject contact: QtObject {
    property int height: 60

    property QtObject backgroundColor: QtObject {
      property color a: ColorsList.add("Timeline_contact_background_a", "g10").color
      property color b: ColorsList.add("Timeline_contact_background_b", "a").color
      property color selected: ColorsList.add("Timeline_contact_background_selected", "i").color
    }

    property QtObject sipAddress: QtObject {
      property QtObject color: QtObject {
        property color normal: ColorsList.add("Timeline_contact_sipAddress_normal", "n").color
        property color selected: ColorsList.add("Timeline_contact_sipAddress_selected", "q").color
      }
    }

    property QtObject username: QtObject {
      property QtObject color: QtObject {
        property color normal: ColorsList.add("Timeline_contact_username_normal", "j").color
        property color selected: ColorsList.add("Timeline_contact_username_selected", "q").color
      }
    }
  }

  property QtObject legend: QtObject {
    property QtObject backgroundColor: QtObject {
      property color normal: ColorsList.add("Timeline_contact_legend_background_normal", "f").color
      property color hovered: ColorsList.add("Timeline_contact_legend_background_hovered", "c").color
    }
    property color color: ColorsList.add("Timeline_contact_legend", "d").color
    property int pointSize: Units.dp * 10
    property int height: 30
    property int iconSize: 14
    property int leftMargin: 17
    property int rightMargin: 17
    property int spacing: 8
  }
}
