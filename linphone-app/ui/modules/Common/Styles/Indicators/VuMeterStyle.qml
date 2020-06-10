pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property int height: 40
  property int width: 5

  property QtObject high: QtObject {
    property QtObject background: QtObject {
      property QtObject color: QtObject {
        property color disabled: Colors.o
        property color enabled: Colors.n
      }
    }

    property QtObject contentItem: QtObject {
      property color color: Colors.b
    }
  }

  property QtObject low: QtObject {
    property QtObject background: QtObject {
      property QtObject color: QtObject {
        property color disabled: Colors.o
        property color enabled: Colors.n
      }
    }

    property QtObject contentItem: QtObject {
      property color color: Colors.j
    }
  }
}
