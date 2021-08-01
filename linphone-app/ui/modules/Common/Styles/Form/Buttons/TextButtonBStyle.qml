// TextButtonBStyle
pragma Singleton
import QtQml 2.2

// =============================================================================

QtObject {
  property QtObject backgroundColor: QtObject {
    property color disabled: Colors.i30.color
    property color hovered: Colors.b.color
    property color normal: Colors.i.color
    property color pressed: Colors.m.color
  }

  property QtObject textColor: QtObject {
    property color disabled: Colors.q.color
    property color hovered: Colors.q.color
    property color normal: Colors.q.color
    property color pressed: Colors.q.color
  }
  property QtObject borderColor : backgroundColor
}
