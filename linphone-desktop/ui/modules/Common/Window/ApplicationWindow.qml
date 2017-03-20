import QtQuick 2.7

// Explicit import to support Toolbar.
import QtQuick.Controls 1.4 as Controls1

import 'Window.js' as Logic

// =============================================================================

Controls1.ApplicationWindow {
  default property alias _content: content.data

  // ---------------------------------------------------------------------------

  function attachVirtualWindow () {
    Logic.attachVirtualWindow.apply(this, arguments)
  }

  function detachVirtualWindow () {
    Logic.detachVirtualWindow()
  }

  // ---------------------------------------------------------------------------

  Item {
    anchors.fill: parent

    Rectangle {
      id: content

      anchors.fill: parent
    }

    VirtualWindow {
      id: virtualWindow
    }
  }
}
