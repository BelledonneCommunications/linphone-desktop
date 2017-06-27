pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
  property int spacing: 0
  property int bottomMargin: 15
  property int leftMargin: 15
  property int rightMargin: 15

  property QtObject actionArea: QtObject {
    property int iconSize: 40
    property int rightButtonsGroupMargin: 15
  }
}
