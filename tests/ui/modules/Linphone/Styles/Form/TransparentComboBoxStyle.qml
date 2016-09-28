pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property QtObject item: QtObject {
    property QtObject color: QtObject {
      property color normal: Colors.k
      property color pressed: Colors.i
      property color selected: Colors.k
    }
  }
}
