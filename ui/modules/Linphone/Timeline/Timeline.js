// =============================================================================
// `Timeline.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

// =============================================================================

function setSelectedEntry (peerAddress, localAddress) {
  if (localAddress != null && localAddress !== Linphone.AccountSettingsModel.sipAddress) {
    resetSelectedEntry()
    return
  }

  var model = timeline.model
  var n = view.count

  timeline._selectedSipAddress = peerAddress

  for (var i = 0; i < n; i++) {
    if (peerAddress === model.data(model.index(i, 0)).sipAddress) {
      view.currentIndex = i
      return
    }
  }
}

function resetSelectedEntry () {
  view.currentIndex = -1
  timeline._selectedSipAddress = ''
}

// -----------------------------------------------------------------------------

function handleDataChanged (topLeft, bottomRight, roles) {
  var index = view.currentIndex
  var model = timeline.model
  var sipAddress = timeline._selectedSipAddress

  if (
    index !== -1 &&
    sipAddress !== model.data(model.index(index, 0)).sipAddress
  ) {
    setSelectedEntry(sipAddress)
  }
}

function handleRowsAboutToBeRemoved (parent, first, last) {
  var index = view.currentIndex
  if (index >= first && index <= last) {
    view.currentIndex = -1
  }
}

function handleCountChanged (_) {
  var sipAddress = timeline._selectedSipAddress
  if (sipAddress.length > 0) {
    setSelectedEntry(sipAddress)
  }
}
