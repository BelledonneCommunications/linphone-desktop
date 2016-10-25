// ===================================================================
// Menu which supports `ListView`.
// ===================================================================

AbstractDropDownMenu {
  property int entryHeight
  property int maxMenuHeight

  function _computeHeight () {
    var model = _content[0].model
    var height = model.count * entryHeight
    return (maxMenuHeight !== undefined && height > maxMenuHeight)
      ? maxMenuHeight
      : height
  }
}
