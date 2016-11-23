import Common 1.0
import Linphone 1.0

// ===================================================================

SearchBox {
  id: searchBox

  delegate: Contact {
    contact: $contact
    width: parent.width

    actions: [
      ActionButton {
        icon: 'call'
        onClicked: CallsWindow.show()
      },

      ActionButton {
        icon: 'video_call'
        onClicked: CallsWindow.show()
      }
    ]
  }
}
