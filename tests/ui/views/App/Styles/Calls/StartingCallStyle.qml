pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property color backgroundColor: Colors.f
  property int actionAreaHeight: 100
  property int contactDescriptionHeight: 60
  property int containerMargins: 20
  property int iconSize: 40
  property int leftButtonsGroupMargin: 50
  property int lowWidth: 415
  property int rightButtonsGroupMargin: 50

  property QtObject avatar: QtObject {
    property color backgroundColor: Colors.w
    property int maxSize: 300
  }

  property QtObject busyIndicator: QtObject {
    property color color: Colors.g
    property int height: 30
    property int width: 30
  }

  property QtObject header: QtObject {
    property int spacing: 10
    property int topMargin: 26
  }

  property QtObject userVideo: QtObject {
    property int height: 90
    property int width: 130
  }
}
