import QtQuick 2.7
import QtQuick.Window 2.2

import Common 1.0
import Common.Styles 1.0
import Utils 1.0

// =============================================================================
// A reusable search input which display a entries model in a menu.
// Each entry can be filtered with the search input.
// =============================================================================

Item {
  id: searchBox

  // ---------------------------------------------------------------------------

  readonly property alias filter: searchField.text

  property alias delegate: list.delegate
  property alias header: list.header
  property alias entryHeight: menu.entryHeight
  property alias maxMenuHeight: menu.maxMenuHeight

  // This property must implement `setFilter` function.
  property alias model: list.model

  property alias placeholderText: searchField.placeholderText

  property bool _isOpen: false

  // ---------------------------------------------------------------------------

  signal menuClosed
  signal menuOpened
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

      onActiveFocusChanged: activeFocus && searchBox.showMenu()
      onTextChanged: _filter(text)
    }

    // -------------------------------------------------------------------------

    SmartConnect {
      Component.onCompleted: {
        var window = searchBox.Window.window

        var handleCoords = function () {
          var point = searchBox.mapToItem(null, 0, searchBox.height)

          desktopPopup.popupX = window.x + point.x
          desktopPopup.popupY = window.y + point.y
        }

        this.connect(window, 'heightChanged', handleCoords)
        this.connect(window, 'widthChanged', handleCoords)
        this.connect(window, 'xChanged', handleCoords)
        this.connect(window, 'yChanged', handleCoords)

        handleCoords()
      }
    }

    // Wrap the search box menu in a window.
    DesktopPopup {
      id: desktopPopup

      // The menu is always below the search field.
      popupX: 0
      popupY: 0

      requestActivate: true

      onVisibleChanged: !visible && searchBox.hideMenu()

      DropDownDynamicMenu {
        id: menu

        launcher: searchField
        width: searchField.width

        // If the menu is focused, the main window loses the active status.
        // So It's necessary to map the keys events.
        Keys.forwardTo: searchField

        onMenuClosed: searchBox.hideMenu()

        ScrollableListView {
          id: list

          anchors.fill: parent
          headerPositioning: header ? ListView.OverlayHeader : ListView.InlineFooter
        }
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
          menu.showMenu()
          desktopPopup.show()

          menuOpened()
        }
      }
    },

    Transition {
      from: 'opened'
      to: ''

      ScriptAction {
        script: {
          menu.hideMenu()
          searchField.focus = false
          desktopPopup.hide()

          menuClosed()
        }
      }
    }
  ]
}
