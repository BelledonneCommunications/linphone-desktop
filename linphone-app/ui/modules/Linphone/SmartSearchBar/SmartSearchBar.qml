import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import Linphone.Styles 1.0

// =============================================================================

SearchBox {
  id: searchBox

  // ---------------------------------------------------------------------------

  readonly property alias isOpen: searchBox._isOpen
  property alias header : view.headerItem

  // ---------------------------------------------------------------------------

  signal addContact (string sipAddress)
  signal launchChat (string sipAddress)
  signal launchCall (string sipAddress)
  signal launchVideoCall (string sipAddress)

  signal entryClicked (var entry)

  // ---------------------------------------------------------------------------

  entryHeight: SipAddressesViewStyle.entry.height

  // ---------------------------------------------------------------------------

  onEnterPressed: {
    var sipAddress = view.interpretableSipAddress
    return sipAddress.length > 0 && SettingsModel.outgoingCallsEnabled && searchBox.launchCall(sipAddress)
  }

  // ---------------------------------------------------------------------------

  SipAddressesView {
    id: view

    actions: [{
      icon: 'video_call',
      handler: function (entry) {
        searchBox.closeMenu()
        searchBox.launchVideoCall(entry.sipAddress)
      },
      visible: SettingsModel.videoSupported && SettingsModel.outgoingCallsEnabled && SettingsModel.showStartVideoCallButton
    }, {
      icon: 'call',
      handler: function (entry) {
        searchBox.closeMenu()
        searchBox.launchCall(entry.sipAddress)
      },
      visible: SettingsModel.outgoingCallsEnabled
    }, {
      icon: SettingsModel.chatEnabled && SettingsModel.showStartChatButton ? 'chat' : 'history',
      handler: function (entry) {
        searchBox.closeMenu()
        searchBox.launchChat(entry.sipAddress)
      }
    }]

    headerButtonDescription: qsTr('addContact')
    headerButtonIcon: 'contact_add'
    headerButtonAction: SettingsModel.contactsEnabled && (function (sipAddress) {
      searchBox.closeMenu()
      searchBox.addContact(sipAddress)
    })

    genSipAddress: searchBox.filter

    model: SearchSipAddressesModel {}

    onEntryClicked: {
      searchBox.closeMenu()
      searchBox.entryClicked(entry)
    }
  }
}
