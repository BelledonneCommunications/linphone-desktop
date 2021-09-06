pragma Singleton
import QtQml 2.2

import ColorsList 1.0
// =============================================================================

QtObject {
  property color color: ColorsList.add("Home_background", "k").color
  property int spacing: 20
}
