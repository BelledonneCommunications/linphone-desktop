pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
  property color color: Colors.k.color
  property int bottomMargin: 35
  property int leftMargin: 90
  property int rightMargin: 90
  property int topMargin: 50

  property QtObject stackAnimation: QtObject {
    property int duration: 400
  }
}
