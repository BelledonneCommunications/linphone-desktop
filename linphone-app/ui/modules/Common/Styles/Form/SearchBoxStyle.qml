pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
  property color shadowColor: ColorsList.add("SearchBox_shadow", "l").color
}
