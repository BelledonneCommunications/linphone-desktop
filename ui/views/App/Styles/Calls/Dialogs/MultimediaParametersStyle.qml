pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
  property int height: 262
  property int width: 450

  property QtObject column: QtObject {
    property int spacing: 24

    property QtObject entry: QtObject {
      property int iconSize: 24
      property int spacing: 10
    }
  }
}
