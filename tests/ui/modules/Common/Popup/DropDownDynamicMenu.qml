import Utils 1.0

// =============================================================================
// Menu which supports `ListView`.
// =============================================================================

AbstractDropDownMenu {
  // Can be computed, but for performance usage, it must be given
  // in attribute.
  property int entryHeight
  property int maxMenuHeight

  function _computeHeight () {
    var list = _content[0]

    Utils.assert(list != null, 'No list found.')
    Utils.assert(Utils.qmlTypeof(list, 'QQuickListView'), 'No list view parameter.')

    var height = list.count * entryHeight

    return (maxMenuHeight !== undefined && height > maxMenuHeight)
      ? maxMenuHeight
      : height
  }
}
