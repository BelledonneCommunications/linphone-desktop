pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property string backgroundColor: Colors.k

  property QtObject shadow: QtObject {
    property int horizontalOffset: 0
    property int radius: 8
    property int samples: 15
    property int verticalOffset: 2

    property string color: Colors.f
  }
}
