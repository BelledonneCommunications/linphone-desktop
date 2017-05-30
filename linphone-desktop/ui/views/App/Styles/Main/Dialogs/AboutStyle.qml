pragma Singleton
import QtQuick 2.7

import Common 1.0

// =============================================================================

QtObject {
  property int height: 225
  property int leftMargin: 25
  property int rightMargin: 25
  property int spacing: 20
  property int width: 400

  property QtObject copyrightBlock: QtObject {
    property int spacing: 10

    property QtObject license: QtObject {
      property color color: Colors.d
      property int fontSize: 10
    }

    property QtObject url: QtObject {
      property color color: Colors.i
      property int fontSize: 10
    }
  }

  property QtObject versionsBlock: QtObject {
    property int iconSize: 48
    property int spacing: 10

    property QtObject appVersion: QtObject {
      property color color: Colors.d
      property int fontSize: 10
    }

    property QtObject coreVersion: QtObject {
      property color color: Colors.d
      property int fontSize: 10
    }
  }
}
