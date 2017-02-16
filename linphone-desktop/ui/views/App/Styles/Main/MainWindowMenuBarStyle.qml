pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property color color: Colors.v
  property int height: 27

  property QtObject menu: QtObject {
    property QtObject text: QtObject {
      property int horizontalMargins: 9
      property int verticalMargins: 4

      property QtObject color: QtObject {
        property color selected: Colors.i
        property color normal: Colors.b
      }
    }

    property QtObject indicator: QtObject {
      property color color: Colors.i
      property int height: 2
    }
  }

  property QtObject separator: QtObject {
    property color color: Colors.u
    property int height: 1
    property int spacing: 4
  }

  property QtObject subMenu: QtObject {
    property QtObject color: QtObject {
      property color selected: Colors.i
      property color normal: Colors.k
    }

    property QtObject text: QtObject {
      property QtObject color: QtObject {
        property color selected: Colors.k
        property color normal: Colors.b
      }
    }
  }
}
