pragma Singleton
import QtQml 2.2

import Units 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.e.color
  property color outsideBackgroundColor: Colors.aa.color

  property QtObject fileChooserButton: QtObject {
    property int margins: 6
    property int size: 20
  }

  property QtObject hoverContent: QtObject {
    property color backgroundColor: Colors.q.color

    property QtObject text: QtObject {
      property color color: Colors.i.color
      property int pointSize: Units.dp * 11
    }
  }

  property QtObject text: QtObject {
    property color color: Colors.d.color
    property int pointSize: Units.dp * 10
  }
}
