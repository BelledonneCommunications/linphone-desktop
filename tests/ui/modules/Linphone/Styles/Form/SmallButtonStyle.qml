pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property QtObject background: QtObject {
    property int height: 22
    property int radius: 10

    property QtObject color: QtObject {
      property color hovered: Colors.n
      property color normal: Colors.m
      property color pressed: Colors.i
    }
  }

  property QtObject text: QtObject {
    property color color: Colors.k

    property int fontSize: 8
  }
}
