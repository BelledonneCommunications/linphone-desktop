pragma Singleton
import QtQml 2.2

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int lineHeight: 35

  property QtObject value: QtObject {
    property QtObject placeholder: QtObject {
      property color color: Colors.w
      property int pointSize: Units.dp * 10
    }

    property QtObject text: QtObject {
      property int padding: 10
    }
  }

  property QtObject titleArea: QtObject  {
    property int spacing: 10
    property int iconSize: 18

    property QtObject text: QtObject {
      property color color: Colors.j
      property int pointSize: Units.dp * 9
      property int width: 130
    }
  }
}
