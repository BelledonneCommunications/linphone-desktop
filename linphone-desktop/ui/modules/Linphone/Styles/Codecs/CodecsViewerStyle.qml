pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int leftMargin: 10

  property QtObject attribute: QtObject {
    property color color: Colors.j
    property int fontSize: 10
    property int height: 40
  }

  property QtObject column: QtObject {
    property int spacing: 5

    property int bitrateWidth: 100
    property int clockRateWidth: 100
    property int recvFmtpWidth: 200
    property int encoderDescriptionWidth: 300
    property int mimeWidth: 100
  }

  property QtObject legend: QtObject {
    property color color: Colors.k
    property int fontSize: 10
    property int height: 50
  }
}
