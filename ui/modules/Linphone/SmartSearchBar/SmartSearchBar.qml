import Common 1.0
import Linphone 1.0

import Linphone.Styles 1.0

// =============================================================================

SearchBox {
  id: searchBox

  // ---------------------------------------------------------------------------

  readonly property alias isOpen: searchBox._isOpen

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
    return sipAddress.length > 0 && searchBox.launchCall(sipAddress)
  }

  // ---------------------------------------------------------------------------

  SipAddressesView {
    id: view

    actions: [{
      icon: 'video_call',
      handler: function (entry) {
        searchBox.closeMenu()
        searchBox.launchVideoCall(entry.sipAddress)
      }
    }, {
      icon: 'call',
      handler: function (entry) {
        searchBox.closeMenu()
        searchBox.launchCall(entry.sipAddress)
      }
    }, {
      icon: 'chat',
      handler: function (entry) {
        searchBox.closeMenu()
        searchBox.launchChat(entry.sipAddress)
      }
    }]

    headerButtonDescription: qsTr('addContact')
    headerButtonIcon: 'contact_add'
    headerButtonAction: (function (sipAddress) {
      searchBox.closeMenu()
      searchBox.addContact(sipAddress)
    })

    genSipAddress: searchBox.filter

    model: SipAddressesProxyModel {}

    onEntryClicked: {
      searchBox.closeMenu()
      searchBox.entryClicked(entry)
    }
  }
}
