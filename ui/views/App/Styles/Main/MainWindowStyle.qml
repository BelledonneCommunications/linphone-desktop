pragma Singleton
import QtQuick 2.7

import Colors 1.0
import Units 1.0

// =============================================================================

QtObject {
  property int menuBurgerSize: 16
  property int newConferenceSize: 40
  property int minimumHeight: 610
  property int minimumWidth: 950
  property int width: 950
  property string title: 'Linphone'

  property QtObject accountStatus: QtObject {
    property int width: 200
  }

  property QtObject autoAnswerStatus: QtObject {
    property int iconSize: 13
    property int width: 24

    property QtObject text: QtObject {
      property int pointSize: Units.dp * 8
      property color color: Colors.j75
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
    property int leftMargin: 20
    property int rightMargin: 20
    property int spacing: 20

    property var background: Rectangle {
      color: Colors.v
    }
  }
}
