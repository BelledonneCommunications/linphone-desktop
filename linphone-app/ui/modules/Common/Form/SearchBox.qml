import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls

import Common 1.0
import Utils 1.0

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
  property alias tooltipText : tooltip.text

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
    searchBox.state = ''
    _isOpen = false
  }

  function openMenu () {
    if (_isOpen) {
      return
    }
    searchBox.state = 'opened'
    _isOpen = true
  }

  function _filter (text) {
    var model = searchBox.view.model
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
      readOnly: !searchBox.enabled
      width: parent.width

      Keys.onEscapePressed: searchBox.closeMenu()
      Keys.onReturnPressed: {
        searchBox.enterPressed()
        searchBox.closeMenu()
      }
      onActiveFocusChanged: {
        if (activeFocus && !_isOpen) {

          searchBox.menuRequested()
          searchBox.openMenu()
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

      onClosed: searchBox.closeMenu()
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
  MouseArea
  {// Just take hover events and set popup to do its automatic close if mouse is not inside field/popup area
      anchors.fill: parent
      onContainsMouseChanged: menu.popup.closePolicy=(containsMouse?Controls.Popup.NoAutoClose:Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutside)
      hoverEnabled:true
      preventStealing: true
      propagateComposedEvents:true
      onPressed: mouse.accepted=false
      onReleased: mouse.accepted=false
      onClicked: mouse.accepted=false
      onDoubleClicked: mouse.accepted=false
      onPressAndHold: mouse.accepted=false
      TooltipArea {
              id:tooltip
              visible: !isOpen && text !== ''
      }
  }

  // ---------------------------------------------------------------------------

  states: State {
    name: 'opened'
  }

  transitions: [
    Transition {
      from: ''
      to: 'opened'

      ScriptAction {
        script: {
          menu.open()

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
          searchField.text = ''

          searchBox.menuClosed()
        }
      }
    }
  ]
}
