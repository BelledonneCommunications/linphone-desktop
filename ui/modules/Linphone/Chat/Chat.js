// =============================================================================
// `Chat.qml` Logic.
// =============================================================================

function initView () {
  chat.tryToLoadMoreEntries = false
  chat.bindToEnd = true
}

function loadMoreEntries () {
  if (chat.atYBeginning && !chat.tryToLoadMoreEntries) {
    chat.tryToLoadMoreEntries = true
    chat.positionViewAtBeginning()
    proxyModel.loadMoreEntries()
  }
}

function getComponentFromEntry (chatEntry) {
  if (chatEntry.fileName) {
    return 'FileMessage.qml'
  }

  if (chatEntry.type === ChatModel.CallEntry) {
    return 'Event.qml'
  }

  return chatEntry.isOutgoing ? 'OutgoingMessage.qml' : 'IncomingMessage.qml'
}

function handleFilesDropped (files) {
  chat.bindToEnd = true
  files.forEach(proxyModel.sendFileMessage)
}

function handleMoreEntriesLoaded (n) {
  chat.positionViewAtIndex(n - 1, ListView.Beginning)
  chat.tryToLoadMoreEntries = false
}

function handleMovementEnded () {
  if (chat.atYEnd) {
    chat.bindToEnd = true
  }
}

function handleMovementStarted () {
  chat.bindToEnd = false
}

function sendMessage (text) {
  textArea.text = ''
  chat.bindToEnd = true
  proxyModel.sendMessage(text)
}
