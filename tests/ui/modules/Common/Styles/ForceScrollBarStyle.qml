pragma Singleton
import QtQuick 2.7

import Common 1.0

QtObject {
  property Rectangle background: Rectangle {
    color: Colors.a
  }

  property Rectangle contentItem: Rectangle {
    implicitHeight: 100
    implicitWidth: 8
    radius: 10
  }

  property QtObject color: QtObject {
    property color hovered: Colors.h
    property color normal: Colors.c
    property color pressed: Colors.b
  }
}
