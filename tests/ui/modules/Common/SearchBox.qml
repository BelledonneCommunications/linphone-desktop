import QtQuick 2.7
import QtQuick.Controls 2.0

import Common.Styles 1.0

// ===================================================================
// A reusable search input which display a entries model in a menu.
// Each entry can be filtered with the search input.
// ===================================================================

Item {
  id: item

  property alias delegate: list.delegate
  property alias entryHeight: menu.entryHeight
  property alias maxMenuHeight: menu.maxMenuHeight

  // This property must implement `setFilterFixedString` and/or
  // `invalidate` functions.
  property alias model: list.model

  property alias placeholderText: searchField.placeholderText

  property bool _isOpen: false

  signal menuClosed
  signal menuOpened

  function _hideMenu () {
    menu.hideMenu()
    shadow.visible = false
    searchField.focus = false
    desktopPopup.hide()

    menuClosed()
  }

  function _showMenu () {
    menu.showMenu()
    shadow.visible = true
    desktopPopup.show()

    menuOpened()
  }

  implicitHeight: searchField.height

  Item {
    implicitHeight: searchField.height + menu.height
    width: parent.width

    TextField {
      id: searchField

      background: SearchBoxStyle.searchFieldBackground
      color: SearchBoxStyle.text.color
      font.pointSize: SearchBoxStyle.text.fontSize
      width: parent.width

      Keys.onEscapePressed: _hideMenu()

      onActiveFocusChanged: activeFocus && _showMenu()
      onTextChanged: {
        model.setFilterFixedString(text)

        if (model.invalidate) {
          model.invalidate()
        }
      }
    }

    PopupShadow {
      id: shadow

      anchors.fill: searchField
      source: searchField
      visible: false
    }

    DesktopPopup {
      id: desktopPopup

      property point coords: {
        var point = searchBox.mapToItem(null, 0, searchBox.height)
        point.x += window.x
        point.y += window.y

        return point
      }

      popupX: coords.x
      popupY: coords.y

      onVisibleChanged: !visible && searchBox._hideMenu()

      DropDownDynamicMenu {
        id: menu

        launcher: searchField
        width: searchField.width

        onMenuClosed: _hideMenu()

        ScrollableListView {
          id: list

          anchors.fill: parent
        }
      }
    }
  }
}
