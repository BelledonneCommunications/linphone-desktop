// =============================================================================
// `Chat.qml` Logic.
// =============================================================================

function initView () {
  chat.tryToLoadMoreEntries = false
  chat.bindToEnd = true
  chat.positionViewAtEnd()
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

function handleCurrentItemChanged (currentItem) {
  // Go to last item only!
  if (!chat.bindToEnd || !currentItem || chat.currentIndex + 1 !== chat.count) {
    return
  }

  var chatHeight = chat.height
  var messageY = currentItem.mapToItem(chat.contentItem, 0, 0).y
  var messageHeight = currentItem.height
  console.log(chat.contentY, chatHeight, messageY)
  if (chat.contentY <= messageY) {
    chat.contentY = messageY
  }
  chat.currentIndex = -1
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

function handleDataChanged (_, bottomRight) {
  var n = chat.count
  var index = bottomRight.row

  if (chat.bindToEnd && index + 1 === n) {
    chat.currentIndex = index
  }
}

function sendMessage (text) {
  textArea.text = ''
  chat.bindToEnd = true
  proxyModel.sendMessage(text)
}
