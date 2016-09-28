pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property QtObject backgroundColor: QtObject {
    property color hovered: Colors.o
    property color normal: Colors.j
    property color pressed: Colors.i
  }

  property QtObject textColor: QtObject {
    property color hovered: Colors.k
    property color normal: Colors.k
    property color pressed: Colors.k
  }
}
