pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
  property int height: 312
  property int width: 450

  property QtObject column: QtObject {
    property int spacing: 24

    property QtObject entry: QtObject {
      property int iconSize: 24
      property int spacing: 10
      property int spacing2: 5
    }
  }
}
