import QtQuick 2.7

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
  id: sipAddressesMenu

  // ---------------------------------------------------------------------------

  property alias relativeTo: menu.relativeTo
  property alias relativeX: menu.relativeX
  property alias relativeY: menu.relativeY

  property var sipAddresses: []

  // ---------------------------------------------------------------------------

  function open () {
    var length = sipAddresses.length
    if (!length) {
      return
    }

    if (length === 1) {
      return sipAddressesMenu.sipAddressClicked(sipAddresses[0])
    }

    menu.open()
  }

  function _fillModel () {
    model.clear()

    sipAddresses.forEach(function (sipAddress) {
      model.append({ $sipAddress: sipAddress })
    })
  }

  // ---------------------------------------------------------------------------

  signal sipAddressClicked (string sipAddress)

  // ---------------------------------------------------------------------------

  onSipAddressesChanged: _fillModel()

  // ---------------------------------------------------------------------------

  DropDownDynamicMenu {
    id: menu

    parent: sipAddressesMenu.parent

    entryHeight: SipAddressesMenuStyle.entry.height
    maxMenuHeight: SipAddressesMenuStyle.maxHeight

    ScrollableListView {
      id: list

      spacing: SipAddressesMenuStyle.spacing
      width: SipAddressesMenuStyle.entry.width

      model: ListModel {
        id: model

        Component.onCompleted: _fillModel()
      }

      delegate: Rectangle {
        height: menu.entryHeight
        width: parent.width

        color: mouseArea.pressed
          ? SipAddressesMenuStyle.entry.color.pressed
          : (
            mouseArea.containsMouse
              ? SipAddressesMenuStyle.entry.color.hovered
              : SipAddressesMenuStyle.entry.color.normal
          )

        Text {
          anchors {
            left: parent.left
            leftMargin: SipAddressesMenuStyle.entry.leftMargin
            right: parent.right
            rightMargin: SipAddressesMenuStyle.entry.rightMargin
          }

          color: SipAddressesMenuStyle.entry.text.color
          elide: Text.ElideRight
          font.pointSize: SipAddressesMenuStyle.entry.text.pointSize
          height: parent.height
          text: $sipAddress
          verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
          id: mouseArea

          anchors.fill: parent
          hoverEnabled: true

          onClicked: {
            menu.close()
            sipAddressesMenu.sipAddressClicked($sipAddress)
          }
        }
      }
    }
  }
}
