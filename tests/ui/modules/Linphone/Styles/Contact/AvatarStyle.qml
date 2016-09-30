pragma Singleton
import QtQuick 2.7

QtObject {
  property QtObject initials: QtObject {
    property color color: '#FFFFFF'

    property int fontSize: 10
  }

  property QtObject mask: QtObject {
    property color color: '#8F8F8F'

    property int radius: 50
  }
}
