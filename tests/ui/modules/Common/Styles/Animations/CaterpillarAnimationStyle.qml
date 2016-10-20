pragma Singleton
import QtQuick 2.7

import Common.Styles 1.0

// ===================================================================

QtObject {
  property int nSpheres: 3

  property QtObject animation: QtObject {
    property int duration: 200
    property int space: 10
  }

  property QtObject sphere: QtObject {
    property color color: Colors.r

    property int size: 10
  }
}
