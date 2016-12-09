pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property QtObject infoBar: QtObject {
    property color color: '#F4F4F4'
    property int avatarSize: 60
    property int height: 80
    property int leftMargin: 40
    property int rightMargin: 20
    property int spacing: 20

    property QtObject buttons: QtObject {
      property int size: 40
      property int spacing: 20
    }

    property QtObject username: QtObject {
      property color color: '#4B5964'
      property int fontSize: 13
    }
  }

  property QtObject buttons: QtObject {
    property int spacing: 20
    property int topMargin: 20
  }

  property QtObject values: QtObject {
    property int bottomMargin: 20
    property int leftMargin: 40
    property int rightMargin: 20
    property int topMargin: 20

    property QtObject separator: QtObject {
      property color color: '#E8E8E8'
      property int height: 1
    }
  }
}
