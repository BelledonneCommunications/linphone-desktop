pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property int lineHeight: 30

  property QtObject value: QtObject {
    property QtObject backgroundColor: QtObject {
      property color focused: '#E6E6E6'
      property color normal: 'transparent'
    }

    property QtObject placeholder: QtObject {
      property color color: '#5A585B'

      property int fontSize: 10
    }

    property QtObject text: QtObject {
      property int padding: 10

      property QtObject color: QtObject {
        property color focused: '#000000'
        property color normal: '#5A585B'
      }
    }
  }

  property QtObject titleArea: QtObject  {
    property int spacing: 10
    property int iconSize: 16

    property QtObject text: QtObject {
      property color color: '#000000'

      property int fontSize: 10
      property int width: 130
    }
  }
}
