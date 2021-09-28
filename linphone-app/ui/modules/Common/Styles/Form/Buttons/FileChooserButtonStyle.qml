pragma Singleton
import QtQml 2.2
import ColorsList 1.0

// =============================================================================

QtObject {
  property QtObject tools: QtObject {
    property int width: 30

    property QtObject button: QtObject {
      property int iconSize: 16

      property QtObject color: QtObject {
        property color hovered: ColorsList.add("FileChooser_hovered", "c").color
        property color normal: ColorsList.add("FileChooser_normal", "f").color
        property color pressed: ColorsList.add("FileChooser_pressed", "c").color
      }
    }
  }
}
