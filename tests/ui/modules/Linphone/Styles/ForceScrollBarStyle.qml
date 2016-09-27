pragma Singleton
import QtQuick 2.7

import Linphone 1.0

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
    property string hovered: Colors.h
    property string normal: Colors.c
    property string pressed: Colors.b
  }
}
