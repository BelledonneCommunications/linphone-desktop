pragma Singleton
import QtQml 2.2


// =============================================================================

QtObject {
  property QtObject background: QtObject {
    property color color: Colors.c.color
    property int height: 4
    property int radius: 2
    property int width: 200

    property QtObject content: QtObject {
      property color color: Colors.m.color
      property int radius: 2
    }
  }

  property QtObject handle: QtObject {
    property int height: 16
    property int radius: 13
    property int width: 16

    property QtObject border: QtObject {
      property QtObject color: QtObject {
        property color normal: Colors.c.color
        property color pressed: Colors.c.color
      }
    }

    property QtObject color: QtObject {
      property color normal: Colors.e.color
      property color pressed: Colors.f.color
    }
  }
}
