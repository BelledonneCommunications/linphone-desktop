pragma Singleton
import QtQuick 2.7

import Common 1.0

QtObject {
  property QtObject legend: QtObject {
    property color color: Colors.d

    property int bottomMargin: 10
    property int fontSize: 13
    property int iconSize: 26
    property int leftMargin: 18
    property int spacing: 16
    property int topMargin: 10
  }

  property QtObject separator: QtObject {
    property color color: Colors.e

    property int height: 1
  }
}
