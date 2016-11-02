pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property color backgroundColor: '#FFFFFF'
  property int spacing: 20

  property QtObject bar: QtObject {
    property color backgroundColor: '#F3F3F3'
    property int height: 60
    property int leftMargin: 18
    property int rightMargin: 18
  }

  property QtObject contact: QtObject {
    property int actionButtonsSize: 36
    property int avatarSize: 30
    property int deleteButtonSize: 18
    property int height: 50
    property int leftMargin: 40
    property int presenceLevelSize: 12
    property int rightMargin: 25
    property int spacing: 15

    property QtObject backgroundColor: QtObject {
      property color normal: '#FFFFFF'
      property color hovered: '#E2E9EF'
    }

    property QtObject border: QtObject {
      property color color: '#E8E8E8'
      property int width: 1
    }

    property QtObject username: QtObject {
      property color color: '#4B5964'
      property int width: 220
    }
  }
}
