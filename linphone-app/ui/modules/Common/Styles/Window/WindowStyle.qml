pragma Singleton
import QtQml 2.2

import Colors 1.0

// =============================================================================

QtObject {
  property QtObject transientWindow: QtObject {
    property color color: Colors.l80
  }
}
