pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property color backgroundColor: ColorsList.add("Contacts_background", "k").color
  property int spacing: 20

  property QtObject bar: QtObject {
    property color backgroundColor: ColorsList.add("Contacts_bar_background", "e").color
    property int height: 60
    property int leftMargin: 18
    property int rightMargin: 18
  }

  property QtObject contact: QtObject {
    property int actionButtonsSize: 36
    property int avatarSize: 30
    property int deleteButtonSize: 22
    property int height: 50
    property int leftMargin: 40
    property int presenceLevelSize: 12
    property int rightMargin: 25
    property int spacing: 15

    property QtObject backgroundColor: QtObject {
      property color normal: ColorsList.add("Contacts_contact_background_normal", "k").color
      property color hovered: ColorsList.add("Contacts_contact_background_hovered", "g10").color
    }

    property QtObject border: QtObject {
      property color color: ColorsList.add("Contacts_contact_border", "f").color
      property int width: 1
    }

    property QtObject indicator: QtObject {
      property color color: ColorsList.add("Contacts_contact_indicator", "i").color
      property int width: 5
    }

    property QtObject presence: QtObject {
      property int pointSize: Units.dp * 10
      property color color: ColorsList.add("Contacts_contact_presence", "n").color
    }

    property QtObject username: QtObject {
      property color color: ColorsList.add("Contacts_contact_username", "j").color
      property int pointSize: Units.dp * 10
      property int width: 220
    }
  }
}
