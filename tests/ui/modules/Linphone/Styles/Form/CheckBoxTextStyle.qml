pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property int radius: 3
  property int size: 18

  property QtObject color: QtObject {
    property color pressed: '#FE5E00'
    property color hovered: '#6E6E6E'
    property color normal: '#8E8E8E'
  }
}
