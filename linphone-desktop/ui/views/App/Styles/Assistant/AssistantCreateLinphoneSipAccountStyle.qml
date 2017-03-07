pragma Singleton
import QtQuick 2.7

// =============================================================================

QtObject {
  property QtObject buttons: QtObject {
    property int spacing: 10

    property QtObject button: QtObject {
      property int height: 40
      property int width: 258
    }
  }
}
