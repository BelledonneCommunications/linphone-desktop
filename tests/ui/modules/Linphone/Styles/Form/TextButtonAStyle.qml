pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property QtObject backgroundColor: QtObject {
    property color hovered: '#232323'
    property color pressed: '#FE5E00'
    property color normal: '#434343'
  }

  property QtObject textColor: QtObject {
    property color hovered: '#FFFFFF'
    property color pressed: '#FFFFFF'
    property color normal: '#FFFFFF'
  }
}
