pragma Singleton
import QtQuick 2.7

import Common 1.0

// ===================================================================

QtObject {
  property color backgroundColor: '#FFFFFF'

  property QtObject bar: QtObject {
    property color color: '#F3F3F3'
    property int height: 60
    property int leftMargin: 18
    property int rightMargin: 18
  }

  property QtObject contacts: QtObject {
    property int spacing: 1
  }
}
