pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property QtObject background: QtObject {
    property int height: 22
    property int radius: 10

    property QtObject color: QtObject {
      property string hovered: Colors.n
      property string normal: Colors.m
      property string pressed: Colors.i
    }
  }

  property QtObject text: QtObject {
    property int fontSize: 8

    property string color: Colors.k
  }
}
