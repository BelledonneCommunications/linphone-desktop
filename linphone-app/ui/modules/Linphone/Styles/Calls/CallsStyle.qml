pragma Singleton
import QtQml 2.2


// =============================================================================

QtObject {
  property QtObject entry: QtObject {
    property int iconActionSize: 35
    property int iconMenuSize: 17
    property int height: 30
    property int width: 200

    property QtObject color: QtObject {
      property color normal: Colors.e.color
      property color selected: Colors.j.color
    }

    property QtObject endCallAnimation: QtObject {
      property color blinkColor: Colors.i.color
      property int duration: 300
      property int loops: 3
    }

    property QtObject sipAddressColor: QtObject {
      property color normal: Colors.n.color
      property color selected: Colors.q.color
    }

    property QtObject usernameColor: QtObject {
      property color normal: Colors.j.color
      property color selected: Colors.q.color
    }
  }
}
