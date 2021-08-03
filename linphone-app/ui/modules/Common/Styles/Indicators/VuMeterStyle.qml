pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
  property int height: 40
  property int width: 5

  property QtObject high: QtObject {
    property QtObject background: QtObject {
      property QtObject color: QtObject {
        property color disabled: Colors.o.color
        property color enabled: Colors.n.color
      }
    }

    property QtObject contentItem: QtObject {
      property color color: Colors.b.color
    }
  }

  property QtObject low: QtObject {
    property QtObject background: QtObject {
      property QtObject color: QtObject {
        property color disabled: Colors.o.color
        property color enabled: Colors.n.color
      }
    }

    property QtObject contentItem: QtObject {
      property color color: Colors.j.color
    }
  }
}
