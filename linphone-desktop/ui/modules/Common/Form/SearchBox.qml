import QtQuick 2.7
import QtQuick.Window 2.2

import Common 1.0
import Utils 1.0

// =============================================================================
// A reusable search input which display a entries model in a menu.
// Each entry can be filtered with the search input.
// =============================================================================

Item {
  id: searchBox

  // ---------------------------------------------------------------------------

  readonly property alias filter: searchField.text
  readonly property alias isOpen: searchBox._isOpen
  readonly property var view: _content[0]

  property alias entryHeight: menu.entryHeight
  property alias maxMenuHeight: menu.maxMenuHeight
  property alias placeholderText: searchField.placeholderText

  default property alias _content: menu._content

  property bool _isOpen: false

  // ---------------------------------------------------------------------------

  signal menuClosed
  signal menuOpened
  signal menuRequested
  signal enterPressed

  // ---------------------------------------------------------------------------

  function closeMenu () {
    if (!_isOpen) {
      return
    }

    _isOpen = false
  }

  function openMenu () {
    if (_isOpen) {
      return
    }

    _isOpen = true
  }

  function _filter (text) {
    var model = searchBox.view.model
    Utils.assert(model.setFilter != null, '`model.setFilter` must be defined.')
    model.setFilter(text)
  }

  function _handleCoords () {
    searchBox.closeMenu()

    var point = searchBox.mapToItem(null, 0, searchBox.height)

    desktopPopup.popupX = window.x + point.x
    desktopPopup.popupY = window.y + point.y
  }

  // ---------------------------------------------------------------------------

  implicitHeight: searchField.height

  Item {
    implicitHeight: searchField.height
    width: parent.width

    TextField {
      id: searchField

      icon: 'search'
      width: parent.width

      Keys.onEscapePressed: searchBox.closeMenu()
      Keys.onReturnPressed: {
        searchBox.closeMenu()
        searchBox.enterPressed()
      }

      onActiveFocusChanged: {
        if (activeFocus && !_isOpen) {
          searchBox.menuRequested()
          searchBox.openMenu()
        }
      }

      onTextChanged: _filter(text)

      InvertedMouseArea {
        anchors.fill: parent
        enabled: searchBox._isOpen

        onPressed: searchBox.closeMenu()
      }
    }

    // -------------------------------------------------------------------------

    Connections {
      target: searchBox.Window.window

      onHeightChanged: _handleCoords()
      onWidthChanged: _handleCoords()

      onXChanged: _handleCoords()
      onYChanged: _handleCoords()

      onVisibilityChanged: _handleCoords()
    }

    // Wrap the search box menu in a window.
    DesktopPopup {
      id: desktopPopup

      requestActivate: true

      onVisibleChanged: !visible && searchBox.closeMenu()

      DropDownDynamicMenu {
        id: menu

        implicitHeight: searchBox.view.height
        width: searchField.width

        // If the menu is focused, the main window loses the active status.
        // So It's necessary to map the keys events.
        Keys.forwardTo: searchField

        onClosed: searchBox.closeMenu()
      }
    }

    Binding {
      target: searchBox.view
      property: 'width'
      value: searchField.width
    }

    Binding {
      target: searchBox.view
      property: 'headerPositioning'
      value: searchBox.view.header ? ListView.OverlayHeader : ListView.InlineFooter
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
          menu.open()
          desktopPopup.open()

          searchBox.menuOpened()
        }
      }
    },

    Transition {
      from: 'opened'
      to: ''

      ScriptAction {
        script: {
          menu.close()
          searchField.focus = false
          desktopPopup.close()

          searchBox.menuClosed()
        }
      }
    }
  ]
}
