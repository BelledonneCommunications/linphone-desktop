pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
  property QtObject transientWindow: QtObject {
    property color color: ColorsList.add("Window_transient", "l80").color
  }
}
