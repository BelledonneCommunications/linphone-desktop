pragma Singleton
import QtQuick 2.7

import Common 1.0

QtObject {
  property int buttonsSpacing: 8

  property QtObject button: QtObject {
    property QtObject color: QtObject {
      property color hovered: Colors.n
      property color normal: Colors.m
      property color pressed: Colors.i
      property color selected: Colors.g
    }
  }
}
