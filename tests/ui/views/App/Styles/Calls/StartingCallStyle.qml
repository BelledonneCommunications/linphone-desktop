pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property color backgroundColor: '#E8E8E8'
  property int actionAreaHeight: 100
  property int contactDescriptionHeight: 60
  property int containerMargins: 20

  property QtObject header: QtObject {
    property int spacing: 10
    property int topMargin: 26
  }

  property QtObject avatar: QtObject {
    property color backgroundColor: '#A1A1A1'
    property int maxSize: 300
  }

  property QtObject callType: QtObject {
    property color color: '#96A5B1'
    property int fontSize: 17
  }
}
