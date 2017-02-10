pragma Singleton
import QtQuick 2.7

// =============================================================================

QtObject {
  property int height: 480
  property int width: 800

  property QtObject validButton: QtObject {
    property int bottomMargin: 30
    property int rightMargin: 30
  }
}
