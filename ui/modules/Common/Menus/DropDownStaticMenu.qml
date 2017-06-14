import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

// =============================================================================

Item {
  id: menu

  // ---------------------------------------------------------------------------

  property alias relativeTo: popup.relativeTo
  property alias relativeX: popup.relativeX
  property alias relativeY: popup.relativeY

  property alias entryHeight: menuContent.entryHeight
  property alias entryWidth: menuContent.entryWidth

  default property alias _content: menuContent.data

  // ---------------------------------------------------------------------------

  signal closed
  signal opened

  // ---------------------------------------------------------------------------

  function open () {
    popup.open()
  }

  function close () {
    popup.close()
  }

  // ---------------------------------------------------------------------------

  visible: false

  // ---------------------------------------------------------------------------

  Popup {
    id: popup

    onOpened: menu.opened()
    onClosed: menu.closed()

    ColumnLayout {
      id: menuContent

      property int entryHeight
      property int entryWidth

      spacing: DropDownStaticMenuStyle.spacing
      height: menu._content.length
      width: menu.entryWidth
    }
  }
}
