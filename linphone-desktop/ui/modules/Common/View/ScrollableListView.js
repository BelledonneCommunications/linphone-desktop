// =============================================================================
// `ScrollableListView.qml` Logic.
// =============================================================================

function positionViewAtEnd () {
  view.interactive = false
  scrollAnimation.start()
  view.interactive = true
}

function getYEnd () {
  return view.originY + view.contentHeight - view.height
}
