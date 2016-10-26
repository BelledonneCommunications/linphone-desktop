import QtQuick 2.7
import QtQuick.Window 2.2

import Utils 1.0

Item {
  id: wrapper

  // Not a private property. Can be used with an id.
  default property alias content: content.data

  property alias popupX: popup.x
  property alias popupY: popup.y

  function show () {
    popup.show()
  }

  function hide () {
    popup.hide()
  }

  x: 0
  y: 0
  height: 0
  width: 0
  visible: false

  Window {
    id: popup

    flags: Qt.SplashScreen
    height: wrapper.content[0] != null ? wrapper.content[0].height : 0
    width: wrapper.content[0] != null ? wrapper.content[0].width : 0

    Item {
      id: content

      // Fake parent.
      property var $parent: wrapper
    }
  }
}
