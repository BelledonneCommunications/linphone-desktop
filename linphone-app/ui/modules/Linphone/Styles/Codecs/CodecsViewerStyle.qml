pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property int leftMargin: 10

  property QtObject attribute: QtObject {
    property int height: 40

    property QtObject background: QtObject {
      property QtObject color: QtObject {
        property color normal: ColorsList.add("Codecs_normal", "a").color
        property color hovered: ColorsList.add("Codecs_hovered", "o").color
      }
    }

    property QtObject dropArea: QtObject {
      property int margins: 5
    }

    property QtObject text: QtObject {
      property color color: ColorsList.add("Codecs_text", "j").color
      property int pointSize: Units.dp * 10
    }
  }

  property QtObject column: QtObject {
    property int bitrateWidth: 120
    property int clockRateWidth: 100
    property int encoderDescriptionWidth: 280
    property int mimeWidth: 100
    property int recvFmtpWidth: 200
    property int spacing: 10
  }

  property QtObject legend: QtObject {
    property color color: ColorsList.add("Codecs_legend", "j").color
    property int pointSize: Units.dp * 10
    property int height: 50
  }
}
