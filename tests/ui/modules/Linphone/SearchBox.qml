import QtQuick 2.7
import QtQuick.Controls 2.0

import Linphone 1.0
import Linphone.Styles 1.0

// ===================================================================

Item {
  id: item

  property alias delegate: list.delegate
  property alias entryHeight: menu.entryHeight
  property alias maxMenuHeight: menu.maxMenuHeight
  property alias model: list.model
  property alias placeholderText: searchField.placeholderText

  signal menuClosed ()
  signal menuOpened ()
  signal searchTextChanged (string text)

  function _hideMenu () {
    menu.hide()
    shadow.visible = false
    searchField.focus = false

    menuClosed()
  }

  function _showMenu () {
    menu.show()
    shadow.visible = true

    menuOpened()
  }

  implicitHeight: searchField.height

  Item {
    implicitHeight: searchField.height + menu.height
    width: parent.width

    TextField {
      id: searchField

      background: SearchBoxStyle.searchFieldBackground
      width: parent.width

      Keys.onEscapePressed: _hideMenu()

      onActiveFocusChanged: activeFocus && _showMenu()
      onTextChanged: searchTextChanged(text)
    }

    DropDownMenu {
      id: menu

      anchors.top: searchField.bottom
      width: searchField.width
      z: Constants.zPopup

      Keys.onEscapePressed: _hideMenu()

      ScrollableListView {
        id: list

        anchors.fill: parent
      }
    }

    InvertedMouseArea {
      enabled: menu.visible
      height: parent.height
      parent: parent
      width: parent.width

      onPressed: _hideMenu()
    }

    PopupShadow {
      id: shadow

      anchors.fill: searchField
      source: searchField
      visible: false
    }
  }
}
