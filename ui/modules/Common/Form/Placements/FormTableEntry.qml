import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================

Item {
  default property var _content
  readonly property int currentHeight: _content ? _content.height : 0

  // ---------------------------------------------------------------------------

  height: currentHeight
  width: parent.maxItemWidth

  Loader {
    active: !!_content
    anchors.fill: parent

    sourceComponent: Item {
      id: item

      data: [ _content ]

      Component.onCompleted: _content.anchors.centerIn = item
    }
  }
}
