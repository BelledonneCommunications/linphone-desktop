import QtQuick 2.7
import QtQuick.Window 2.2

// ===================================================================

Item {
  id: wrapper

  property alias popupX: popup.x
  property alias popupY: popup.y

  default property alias _content: content.data

  function show () {
    popup.show()
  }

  function hide () {
    popup.hide()
  }

  // DO NOT TOUCH THIS PROPERTIES.

  // No visible.
  visible: false

  // No size, no position.
  height: 0
  width: 0
  x: 0
  y: 0

  Window {
    id: popup

    flags: Qt.SplashScreen
    height: _content[0] != null ? _content[0].height : 0
    width: _content[0] != null ? _content[0].width : 0

    Item {
      id: content

      // Fake parent.
      property var $parent: wrapper
    }
  }
}
