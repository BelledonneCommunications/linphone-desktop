pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property QtObject background: QtObject {
    property int height: 22
    property int radius: 10

    property QtObject color: QtObject {
      property string hovered: '#C0C0C0'
      property string normal: '#D1D1D1'
      property string pressed: '#FE5E00'
    }
  }

  property QtObject text: QtObject {
    property int fontSize: 8

    property string color: '#FFFFFF'
  }
}
