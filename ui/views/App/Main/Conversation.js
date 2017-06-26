// =============================================================================
// `Conversation.qml` Logic.
// =============================================================================

.import Linphone 1.0 as Linphone

.import 'qrc:/ui/scripts/LinphoneUtils/linphone-utils.js' as LinphoneUtils
.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function removeAllEntries () {
  window.attachVirtualWindow(Utils.buildDialogUri('ConfirmDialog'), {
    descriptionText: qsTr('removeAllEntriesDescription'),
  }, function (status) {
    if (status) {
      chatProxyModel.removeAllEntries()
    }
  })
}

function getAvatar () {
  var contact = conversation._sipAddressObserver.contact
  return contact ? contact.vcard.avatar : ''
}

function getEditIcon () {
  return conversation._sipAddressObserver.contact ? 'contact_edit' : 'contact_add'
}

function getUsername () {
  return LinphoneUtils.getContactUsername(conversation._sipAddressObserver)
}

function updateChatFilter (button) {
  if (button === 0) {
    chatProxyModel.setEntryTypeFilter(Linphone.ChatModel.GenericEntry)
  } else if (button === 1) {
    chatProxyModel.setEntryTypeFilter(Linphone.ChatModel.CallEntry)
  } else {
    chatProxyModel.setEntryTypeFilter(Linphone.ChatModel.MessageEntry)
  }
}
