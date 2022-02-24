pragma Singleton
import QtQml 2.2

import ColorsList 1.0
import Units 1.0

// =============================================================================

QtObject {
	property string sectionName: 'About'
  property int height: 255
  property int spacing: 20
  property int width: 400

  property QtObject copyrightBlock: QtObject {
    property int spacing: 10

    property QtObject license: QtObject {
      property color color: ColorsList.add(sectionName+'_license', 'd').color
      property int pointSize: Units.dp * 10
    }

    property QtObject url: QtObject {
      property color color: ColorsList.add(sectionName+'_url', 'i').color
      property int pointSize: Units.dp * 10
    }
  }

  property QtObject versionsBlock: QtObject {
    property int iconSize: 48
    property int spacing: 10

    property QtObject appVersion: QtObject {
      property color color: ColorsList.add(sectionName+'_appVersion', 'd').color
      property int pointSize: Units.dp * 10
    }

    property QtObject coreVersion: QtObject {
      property color color: ColorsList.add(sectionName+'_coreVersion', 'd').color
      property int pointSize: Units.dp * 10
    }
  }
}
