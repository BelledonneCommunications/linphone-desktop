import QtQuick 2.7
import QtQuick.Controls 2.2

import 'Window.js' as Logic

// =============================================================================

ApplicationWindow {
  id: window

  default property alias _content: content.data

  readonly property bool virtualWindowVisible: virtualWindow.active

  // ---------------------------------------------------------------------------

  signal attachedVirtualWindow
  signal detachedVirtualWindow

  // ---------------------------------------------------------------------------

  function attachVirtualWindow (component, properties, exitStatusHandler) {
    Logic.attachVirtualWindow.call(this, component, properties, exitStatusHandler)
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
