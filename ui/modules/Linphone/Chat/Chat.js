// =============================================================================
// `Chat.qml` Logic.
// =============================================================================

.import QtQuick 2.7 as QtQuick

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/LinphoneUtils/linphone-utils.js' as LinphoneUtils

// =============================================================================

function initView () {
  chat.tryToLoadMoreEntries = false
  chat.bindToEnd = true
}

function loadMoreEntries () {
  if (chat.atYBeginning && !chat.tryToLoadMoreEntries) {
    chat.tryToLoadMoreEntries = true
    chat.positionViewAtBeginning()
    container.proxyModel.loadMoreEntries()
  }
}

function getComponentFromEntry (chatEntry) {
  if (chatEntry.fileName) {
    return 'FileMessage.qml'
  }

  if (chatEntry.type === Linphone.ChatModel.CallEntry) {
    return 'Event.qml'
  }

  return chatEntry.isOutgoing ? 'OutgoingMessage.qml' : 'IncomingMessage.qml'
}

function getIsComposingMessage () {
  if (!container.proxyModel.isRemoteComposing) {
    return ''
  }

  var sipAddressObserver = chat.sipAddressObserver
  return qsTr('isComposing').replace(
    '%1',
    LinphoneUtils.getContactUsername(sipAddressObserver)
  )
}

function handleFilesDropped (files) {
  chat.bindToEnd = true
  files.forEach(container.proxyModel.sendFileMessage)
}

function handleMoreEntriesLoaded (n) {
  chat.positionViewAtIndex(n - 1, QtQuick.ListView.Beginning)
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

function handleTextChanged () {
  container.proxyModel.compose()
}

function sendMessage (text) {
  textArea.text = ''
  chat.bindToEnd = true
  container.proxyModel.sendMessage(text)
}
