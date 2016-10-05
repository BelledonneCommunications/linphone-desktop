pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property QtObject handle: QtObject {
    property int width: 8

    property QtObject color: QtObject {
      property color hovered: '#707070'
      property color normal: '#C5C5C5'
      property color pressed: '#5E5E5E'
    }
  }
}
