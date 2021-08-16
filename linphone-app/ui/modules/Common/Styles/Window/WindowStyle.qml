pragma Singleton
import QtQml 2.2


// =============================================================================

QtObject {
  property QtObject transientWindow: QtObject {
    property color color: Colors.l80.color
  }
}
