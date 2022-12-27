pragma Singleton
import QtQml 2.2

import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'Popup'
  property var backgroundColor: ColorsList.add(sectionName+'_bg', 'k')

  property QtObject shadow: QtObject {
    property var colorModel: ColorsList.add(sectionName+'_shadow', 'l')
    property int horizontalOffset: 2
    property int radius: 10
    property int samples: 15
    property int verticalOffset: 2
  }
}
