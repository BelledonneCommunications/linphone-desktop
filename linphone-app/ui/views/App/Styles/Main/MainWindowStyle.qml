pragma Singleton
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
  property int menuBurgerSize: 16
  property int newConferenceSize: 40
  property int minimumHeight: 610
  property int minimumWidth: 950
  property int width: 950
  property int panelButtonSize : 20
  property int homeButtonSize: 40

  property QtObject accountStatus: QtObject {
    property int width: 200
  }

  property QtObject autoAnswerStatus: QtObject {
    property int iconSize: 16
    property int width: 28

    property QtObject text: QtObject {
      property int pointSize: Units.dp * 8
      property color color: ColorsList.add("MainWindow_auto_answer_text", "i").color
    }
  }

  property QtObject menu: QtObject {
    property int height: 50
    property int width: 250
  }

  property QtObject searchBox: QtObject {
    property int maxHeight: 300 // See Hick's law for good choice.
  }

  property QtObject toolBar: QtObject {
    property int height: 70
    property int leftMargin: 18
    property int rightMargin: 18
    property int spacing: 16

    property var background: Rectangle {
      color: ColorsList.add("MainWindow_toolbar_background", "f").color
    }
  }
}
