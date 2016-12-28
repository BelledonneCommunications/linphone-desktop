pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int lineHeight: 35

  property QtObject value: QtObject {
    property QtObject placeholder: QtObject {
      property color color: Colors.w
      property int fontSize: 10
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
      property int fontSize: 9
      property int width: 130
    }
  }
}
