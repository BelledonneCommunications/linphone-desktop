import Utils 1.0

// =============================================================================
// Menu which supports menu like `ActionMenu` or `Menu`.
// =============================================================================

AbstractDropDownMenu {
  function _computeHeight () {
    return _content[0].height
  }
}
