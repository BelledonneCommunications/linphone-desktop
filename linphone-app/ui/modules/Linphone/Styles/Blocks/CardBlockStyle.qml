pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property int spacing: 30
  property int width: 200

  property QtObject content: QtObject {
    property int height: 40
  }

  property QtObject description: QtObject {
    property color color: ColorsList.add("CardBlock_description", "n").color
    property int pointSize: Units.dp * 10
    property int height: 40
  }

  property QtObject icon: QtObject {
    property int bottomMargin: 20
    property int size: 148
  }

  property QtObject title: QtObject {
    property color color: ColorsList.add("CardBlock_title", "j").color
    property int bottomMargin: 10
    property int pointSize: Units.dp * 10
    property int height: 20
  }
}
