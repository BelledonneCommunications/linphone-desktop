import QtQuick 2.7

import Common 1.0
import Utils 1.0

// =============================================================================
// Specific GNU/Linux version of `SearchBox` component.
// =============================================================================

Item {
  id: searchBox

  // ---------------------------------------------------------------------------

  readonly property alias filter: searchField.text

  property alias delegate: list.delegate
  property alias header: list.header
  property alias entryHeight: menu.entryHeight
  property alias maxMenuHeight: menu.maxMenuHeight

  property alias model: list.model
  property alias placeholderText: searchField.placeholderText

  property bool _isOpen: false

  // ---------------------------------------------------------------------------

  signal menuClosed
  signal menuOpened
  signal menuRequested
  signal enterPressed

  // ---------------------------------------------------------------------------

  function hideMenu () {
    if (!_isOpen) {
      return
    }

    _isOpen = false
  }

  function showMenu () {
    if (_isOpen) {
      return
    }

    _isOpen = true
  }

  function _filter (text) {
    Utils.assert(model.setFilter != null, '`model.setFilter` must be defined.')
    model.setFilter(text)
  }

  // ---------------------------------------------------------------------------

  implicitHeight: searchField.height

  Item {
    implicitHeight: searchField.height + menu.height
    width: parent.width

    TextField {
      id: searchField

      icon: 'search'
      width: parent.width

      Keys.onEscapePressed: searchBox.hideMenu()
      Keys.onReturnPressed: {
        searchBox.hideMenu()
        searchBox.enterPressed()
      }

      onActiveFocusChanged: {
        if (activeFocus && !_isOpen) {
          searchBox.menuRequested()
          searchBox.showMenu()
        }
      }

      onTextChanged: _filter(text)
    }

    // -------------------------------------------------------------------------

    DropDownDynamicMenu {
      id: menu

      relativeTo: searchField
      relativeY: searchField.height

      // If the menu is focused, the main window loses the active status.
      // So It's necessary to map the keys events.
      Keys.forwardTo: searchField

      onMenuClosed: searchBox.hideMenu()

      ScrollableListView {
        id: list

        headerPositioning: header ? ListView.OverlayHeader : ListView.InlineFooter
        width: searchField.width
      }
    }
  }

  // ---------------------------------------------------------------------------

  states: State {
    name: 'opened'
    when: _isOpen
  }

  transitions: [
    Transition {
      from: ''
      to: 'opened'

      ScriptAction {
        script: {
          menu.show()

          searchBox.menuOpened()
        }
      }
    },

    Transition {
      from: 'opened'
      to: ''

      ScriptAction {
        script: {
          menu.hide()
          searchField.focus = false

          searchBox.menuClosed()
        }
      }
    }
  ]
}
