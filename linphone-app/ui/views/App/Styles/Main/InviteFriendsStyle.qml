pragma Singleton
import QtQml 2.2


// =============================================================================

QtObject {
  property color color: Colors.k.color
  property int width: 400

  property QtObject message: QtObject {
    property int height: 140
  }

  property QtObject buttons: QtObject {
    property int bottomMargin: 35
    property int spacing: 10
  }
}
