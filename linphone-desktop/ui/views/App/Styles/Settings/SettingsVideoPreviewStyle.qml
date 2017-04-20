pragma Singleton
import QtQuick 2.7

// =============================================================================

QtObject {
  property int height: 480
  property int width: 640

  property QtObject preview: QtObject {
    property int leftMargin: 25
    property int rightMargin: 25
  }
}
