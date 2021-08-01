pragma Singleton
import QtQml 2.2


// =============================================================================

QtObject {
  property color backgroundColor: Colors.k.color

  property QtObject shadow: QtObject {
    property color color: Colors.l.color
    property int horizontalOffset: 2
    property int radius: 10
    property int samples: 15
    property int verticalOffset: 2
  }
}
