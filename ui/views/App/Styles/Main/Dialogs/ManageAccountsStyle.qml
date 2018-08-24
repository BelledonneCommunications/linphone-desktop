pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
  property int height: 303
  property int heightWithoutPresence: 234
  property int width: 450

  property QtObject accountSelector: QtObject {
    property int height: 126
  }
}
