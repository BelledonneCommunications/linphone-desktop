pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
  property QtObject ringPlayer: QtObject {
    property int leftMargin: 10
  }
  property QtObject warningMessage: QtObject {
    property int iconSize: 20
  }
}
