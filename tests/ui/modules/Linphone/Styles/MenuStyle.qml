pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property int spacing: 2

  property QtObject entry: QtObject {
    property int iconSize: 24
    property int leftMargin: 20
    property int rightMargin: 20
    property int selectionIconSize: 12
    property int spacing: 18

    property QtObject color: QtObject {
      property color hovered: Colors.h
      property color normal: Colors.g
      property color pressed: Colors.i
      property color selected: Colors.j
    }

    property QtObject text: QtObject {
      property color color: Colors.k

      property int fontSize: 13
    }
  }
}
