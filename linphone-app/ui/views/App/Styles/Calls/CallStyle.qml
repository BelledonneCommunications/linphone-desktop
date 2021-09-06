pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property color backgroundColor: ColorsList.add("Call_background", "f").color

  property QtObject actionArea: QtObject {
    property int height: 100
    property int iconSize: 40
    property int leftButtonsGroupMargin: 50
    property int lowWidth: 650
    property int rightButtonsGroupMargin: 50

    property QtObject userVideo: QtObject {
      property int height: 200
      property int width: 130
      property int heightReference: 1200 // height and width are fixed from these references
      property int widthReference: 780
    }

    property QtObject vu: QtObject {
      property int spacing: 5
    }

    property QtObject callError: QtObject {
      property color color: ColorsList.add("Call_action_error", "i").color
      property int pointSize: Units.dp * 12
    }
  }

  property QtObject container: QtObject {
    property int margins: 15

    property QtObject avatar: QtObject {
      property color backgroundColor: ColorsList.add("Call_container_avatar_background", "n").color
      property int maxSize: 300
    }

    property QtObject pause: QtObject {
      property color color: ColorsList.add("Call_container_pause", "g90").color

      property QtObject text: QtObject {
        property color color: ColorsList.add("Call_container_pause_text", "q").color
        property int pointSizeFactor: 10
      }
    }
  }

  property QtObject header: QtObject {
    property int buttonIconSize: 40
    property int iconSize: 16
    property int leftMargin: 20
    property int rightMargin: 20
    property int spacing: 10
    property int topMargin: 26

    property QtObject busyIndicator: QtObject {
      property color color: ColorsList.add("Call_header_busy", "g").color
      property int height: 30
      property int width: 30
    }

    property QtObject contactDescription: QtObject {
      property int height: 50
      property int width: 150
    }

    property QtObject elapsedTime: QtObject {
      property color color: ColorsList.add("Call_header_elapsed_time", "j").color
      property int pointSize: Units.dp * 10

      property QtObject fullscreen: QtObject {
        property int pointSize: Units.dp * 12
      }
    }

    property QtObject stats: QtObject {
      property int relativeY: 90
    }
  }

  property QtObject zrtpArea: QtObject {
    property int height: 50

    property QtObject buttons: QtObject {
      property int spacing: 10
    }

    property QtObject text: QtObject {
      property color colorA: ColorsList.add("Call_zrtp_text_a", "j").color
      property color colorB: ColorsList.add("Call_zrtp_text_b", "i").color
      property int pointSize: Units.dp * 10
      property int wordsSpacing: 5
    }
  }
}
