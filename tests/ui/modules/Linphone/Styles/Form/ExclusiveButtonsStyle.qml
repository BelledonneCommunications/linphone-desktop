pragma Singleton
import QtQuick 2.7

import Linphone 1.0

QtObject {
  property int buttonsSpacing: 8

  property QtObject button: QtObject {
    property QtObject color: QtObject {
      property string hovered: Colors.n
      property string normal: Colors.m
      property string pressed: Colors.i
      property string selected: Colors.g
    }
  }
}
