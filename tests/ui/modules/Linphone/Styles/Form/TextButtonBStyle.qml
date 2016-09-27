pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property QtObject backgroundColor: QtObject {
    property color hovered: '#B1B1B1'
    property color pressed: '#FE5E00'
    property color normal: '#D1D1D1'
  }

  property QtObject textColor: QtObject {
    property color hovered: '#5A585B'
    property color pressed: '#FFFFFF'
    property color normal: '#5A585B'
  }
}
