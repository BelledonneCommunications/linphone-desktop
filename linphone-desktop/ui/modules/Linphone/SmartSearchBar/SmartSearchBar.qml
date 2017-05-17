import Common 1.0
import Linphone 1.0

import Linphone.Styles 1.0

// =============================================================================

SearchBox {
  id: searchBar

  // ---------------------------------------------------------------------------

  readonly property alias isOpen: searchBar._isOpen

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
    return sipAddress.length > 0 && searchBar.launchCall(sipAddress)
  }

  // ---------------------------------------------------------------------------

  SipAddressesView {
    id: view

    actions: [{
      icon: 'video_call',
      handler: function (entry) {
        searchBar.closeMenu()
        searchBar.launchVideoCall(entry.sipAddress)
      }
    }, {
      icon: 'call',
      handler: function (entry) {
        searchBar.closeMenu()
        searchBar.launchCall(entry.sipAddress)
      }
    }, {
      icon: 'chat',
      handler: function (entry) {
        searchBar.closeMenu()
        searchBar.launchChat(entry.sipAddress)
      }
    }]

    headerButtonDescription: qsTr('addContact')
    headerButtonIcon: 'contact_add'
    headerButtonAction: (function (sipAddress) {
      searchBar.closeMenu()
      searchBar.addContact(sipAddress)
    })

    genSipAddress: searchBar.filter

    onEntryClicked: {
      searchBar.closeMenu()
      searchBar.entryClicked(entry)
    }
  }
}
