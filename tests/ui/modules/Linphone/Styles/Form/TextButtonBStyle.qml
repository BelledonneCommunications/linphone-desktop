pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property QtObject backgroundColor: QtObject {
    property color hovered: Colors.p
    property color pressed: Colors.i
    property color normal: Colors.m
  }

  property QtObject textColor: QtObject {
    property color hovered: Colors.d
    property color pressed: Colors.k
    property color normal: Colors.d
  }
}
