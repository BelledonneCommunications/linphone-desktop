pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.f

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
      property color color: Colors.i
      property int pointSize: Units.dp * 12
    }
  }

  property QtObject container: QtObject {
    property int margins: 15

    property QtObject avatar: QtObject {
      property color backgroundColor: Colors.n
      property int maxSize: 300
    }

    property QtObject pause: QtObject {
      property color color: Colors.g90

      property QtObject text: QtObject {
        property color color: Colors.q
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
      property color color: Colors.g
      property int height: 30
      property int width: 30
    }

    property QtObject contactDescription: QtObject {
      property int height: 50
      property int width: 150
    }

    property QtObject elapsedTime: QtObject {
      property color color: Colors.j
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
      property color colorA: Colors.j
      property color colorB: Colors.i
      property int pointSize: Units.dp * 10
      property int wordsSpacing: 5
    }
  }
}
