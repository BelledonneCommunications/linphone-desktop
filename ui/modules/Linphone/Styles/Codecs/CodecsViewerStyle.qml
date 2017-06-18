pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int leftMargin: 10

  property QtObject attribute: QtObject {
    property int height: 40

    property QtObject background: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.a
        property color hovered: Colors.y
      }
    }

    property QtObject dropArea: QtObject {
      property int margins: 5
    }

    property QtObject text: QtObject {
      property color color: Colors.j
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
    property color color: Colors.j
    property int pointSize: Units.dp * 10
    property int height: 50
  }
}
