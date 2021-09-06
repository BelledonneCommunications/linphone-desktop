pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
  property color color: ColorsList.add("ConferenceControls", "e").color
  property int height: 60
  property int leftMargin: 12
  property int rightMargin: 12
}
