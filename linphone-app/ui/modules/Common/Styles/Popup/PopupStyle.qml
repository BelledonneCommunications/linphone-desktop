pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'Popup'
  property color backgroundColor: ColorsList.add(sectionName+'_bg', 'k').color

  property QtObject shadow: QtObject {
    property color color: ColorsList.add(sectionName+'_shadow', 'l').color
    property int horizontalOffset: 2
    property int radius: 10
    property int samples: 15
    property int verticalOffset: 2
  }
}
