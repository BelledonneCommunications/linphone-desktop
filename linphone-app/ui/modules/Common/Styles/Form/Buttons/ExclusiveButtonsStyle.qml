pragma Singleton
import QtQml 2.2


// =============================================================================

QtObject {
  property int buttonsSpacing: 8

  property QtObject button: QtObject {
    property QtObject color: QtObject {
      property color hovered: Colors.n.color
      property color normal: Colors.x.color
      property color pressed: Colors.i.color
      property color selected: Colors.g.color
    }
  }
}
