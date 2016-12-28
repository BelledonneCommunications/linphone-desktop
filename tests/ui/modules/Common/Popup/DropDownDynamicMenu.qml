import QtQuick 2.7

import Common 1.0
import Utils 1.0

// =============================================================================
// Menu which supports `ListView`.
// =============================================================================

AbstractDropDownMenu {
  // Can be computed, but for performance usage, it must be given in attribute.
  property int entryHeight
  property int maxMenuHeight

  function _computeHeight () {
    Utils.assert(_content != null && _content.length > 0, '`_content` cannot be null and must exists.')

    var list = _content[0]
    Utils.assert(list != null, 'No list found.')
    Utils.assert(Utils.qmlTypeof(list, 'QQuickListView'), 'No list view parameter.')

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
}
