pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property int lineHeight: 30

  property QtObject value: QtObject {
    property QtObject backgroundColor: QtObject {
      property color focused: Colors.q
      property color normal: 'transparent'
    }

    property QtObject placeholder: QtObject {
      property color color: Colors.d

      property int fontSize: 10
    }

    property QtObject text: QtObject {
      property int padding: 10

      property QtObject color: QtObject {
        property color focused: Colors.l
        property color normal: Colors.d
      }
    }
  }

  property QtObject titleArea: QtObject  {
    property int spacing: 10
    property int iconSize: 16

    property QtObject text: QtObject {
      property color color: Colors.l

      property int fontSize: 10
      property int width: 130
    }
  }
}
