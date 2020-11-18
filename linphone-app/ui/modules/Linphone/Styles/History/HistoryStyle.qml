pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property color color: Colors.q

  property QtObject sectionHeading: QtObject {
    property int padding: 5
    property int bottomMargin: 20

    property QtObject border: QtObject {
      property color color: Colors.g10
      property int width: 1
    }

    property QtObject text: QtObject {
      property int pointSize: Units.dp * 10
      property color color: Colors.g
    }
  }


  property QtObject entry: QtObject {
    property int bottomMargin: 10
    property int deleteIconSize: 22
    property int leftMargin: 18
    property int lineHeight: 30
    property int metaWidth: 40

    property QtObject event: QtObject {
      property int iconSize: 18

      property QtObject text: QtObject {
        property color color: Colors.d
        property int pointSize: Units.dp * 10
      }
    }
    
    property QtObject message: QtObject {
      property int padding: 8
      property int radius: 4

      property QtObject extraContent: QtObject {
        property int leftMargin: 10
        property int spacing: 5
        property int rightMargin: 5
      }
    }

    property QtObject time: QtObject {
      property color color: Colors.d
      property int pointSize: Units.dp * 10
      property int width: 44
    }
  }
}
