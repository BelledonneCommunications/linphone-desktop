import QtQuick 2.7

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================
// SipAddressesMenu
Item {
  id: sipAddressesMenu

  // ---------------------------------------------------------------------------

  property alias relativeTo: menu.relativeTo
  property alias relativeX: menu.relativeX
  property alias relativeY: menu.relativeY

  property var sipAddresses: []

  // ---------------------------------------------------------------------------

  function open (callback) {
    var length = sipAddresses.length
    if (!length) {
      return
    }

    if (length === 1) {
		if(callback)
			return callback(sipAddresses[0])
		else
			return sipAddressesMenu.sipAddressClicked(sipAddresses[0])
    }
	menu.callback = callback
    menu.open()
  }

  function _fillModel () {
    model.clear()

    sipAddresses.forEach(function (sipAddress) {
      model.append({ $modelData: sipAddress })
    })
  }

  // ---------------------------------------------------------------------------

  signal sipAddressClicked (string sipAddress)

  // ---------------------------------------------------------------------------

  onSipAddressesChanged: _fillModel()

  // ---------------------------------------------------------------------------

  DropDownDynamicMenu {
    id: menu
    property var callback

    parent: sipAddressesMenu.parent
    
	relativeTo: sipAddressesMenu.parent
	relativeY: sipAddressesMenu.parent.height

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
        width: list.width

        color: mouseArea.pressed
          ? SipAddressesMenuStyle.entry.color.pressed.color
          : (
            mouseArea.containsMouse
              ? SipAddressesMenuStyle.entry.color.hovered.color
              : SipAddressesMenuStyle.entry.color.normal.color
          )

        Text {
          anchors {
            left: parent.left
            leftMargin: SipAddressesMenuStyle.entry.leftMargin
            right: parent.right
            rightMargin: SipAddressesMenuStyle.entry.rightMargin
          }

          color: SipAddressesMenuStyle.entry.text.colorModel.color
          elide: Text.ElideRight
          font.pointSize: SipAddressesMenuStyle.entry.text.pointSize
          height: parent.height
          text: $modelData
          verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
          id: mouseArea

          anchors.fill: parent

          onClicked: {
            menu.close()
            if( menu.callback)
				menu.callback($modelData)
			else
				sipAddressesMenu.sipAddressClicked($modelData)
          }
        }
      }
    }
  }
}
