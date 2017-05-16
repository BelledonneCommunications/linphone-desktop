import QtQuick 2.7

import Common 1.0
import Utils 1.0

// =============================================================================

Item {
  id: menu

  // ---------------------------------------------------------------------------

  property alias relativeTo: popup.relativeTo
  property alias relativeX: popup.relativeX
  property alias relativeY: popup.relativeY

  // Can be computed, but for performance usage, it must be given in attribute.
  property int entryHeight
  property int maxMenuHeight

  default property alias _content: menuContent.data

  // ---------------------------------------------------------------------------

  signal menuClosed
  signal menuOpened

  // ---------------------------------------------------------------------------

  function show () {
    popup.show()
  }

  function hide () {
    popup.hide()
  }

  // ---------------------------------------------------------------------------

  function _computeHeight () {
    Utils.assert(_content != null && _content.length > 0, '`_content` cannot be null and must exists.')

    var list = _content[0]
    Utils.assert(list != null, 'No list found.')
    Utils.assert(
      Utils.qmlTypeof(list, 'QQuickListView') || Utils.qmlTypeof(list, 'ScrollableListView'),
      'No list view parameter.'
    )

    var height = list.count * entryHeight

    if (list.headerPositioning === ListView.OverlayHeader) {
      // Workaround to force header layout.
      list.headerItem.z = Constants.zMax

      height += list.headerItem.height
    }

    return (maxMenuHeight !== undefined && height > maxMenuHeight)
      ? maxMenuHeight
      : height
  }

  // ---------------------------------------------------------------------------

  Popup {
    id: popup

    onShown: menu.menuOpened()
    onHidden: menu.menuClosed()

    Item {
      id: menuContent

      height: menu._computeHeight()
      width: menu._content[0].width
    }
  }

  Binding {
    property: 'height'
    target: menu._content[0]
    value: menuContent.height
  }
}
