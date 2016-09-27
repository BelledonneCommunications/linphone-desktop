pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property int buttonsSpacing: 8

  property QtObject button: QtObject {
    property QtObject color: QtObject {
      property string hovered: '#C0C0C0'
      property string normal: '#D1D1D1'
      property string pressed: '#FE5E00'
      property string selected: '#8E8E8E'
    }
  }
}
