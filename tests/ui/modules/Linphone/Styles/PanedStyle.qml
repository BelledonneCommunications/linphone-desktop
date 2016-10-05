pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property QtObject handle: QtObject {
    property int width: 8

    property QtObject color: QtObject {
      property color hovered: Colors.h
      property color normal: Colors.c
      property color pressed: Colors.b
    }
  }
}
