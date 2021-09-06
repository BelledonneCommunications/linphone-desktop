pragma Singleton
import QtQml 2.2
import ColorsList 1.0

// =============================================================================

QtObject {
  property QtObject bar: QtObject {
    property color backgroundColor: ColorsList.add("HistoryView_bar_background", "e").color
    property int avatarSize: 60
    property int height: 80
    property int leftMargin: 40
    property int rightMargin: 30
    property int spacing: 20

    property QtObject actions: QtObject {
      property int spacing: 40

      property QtObject call: QtObject {
        property int iconSize: 40
      }

      property QtObject del: QtObject {
        property int iconSize: 22
      }

      property QtObject edit: QtObject {
        property int iconSize: 22
      }
    }

    property QtObject description: QtObject {
      property color sipAddressColor: ColorsList.add("HistoryView_bar_description_sipAddress", "g").color
      property color usernameColor: ColorsList.add("HistoryView_bar_description_username", "j").color
    }
  }

  property QtObject filters: QtObject {
    property color backgroundColor: ColorsList.add("HistoryView_filters_background", "q").color
    property int height: 51
    property int leftMargin: 40

    property QtObject border: QtObject {
      property color color: ColorsList.add("HistoryView_filters_border", "g10").color
      property int bottomWidth: 1
      property int topWidth: 0
    }
  }
}
