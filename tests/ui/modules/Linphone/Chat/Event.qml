import QtQuick 2.7

import Common 1.0
import Linphone.Styles 1.0
import Utils 1.0

// ===================================================================

Row {
  height: ChatStyle.entry.lineHeight
  spacing: ChatStyle.entry.message.extraContent.spacing

  Icon {
    height: parent.height
    icon: $content
    iconSize: ChatStyle.entry.event.iconSize
    width: ChatStyle.entry.metaWidth
  }

  Text {
    Component {
      // Never created.
      // Private data for `lupdate`.
      Item {
        property var i18n: [
          QT_TR_NOOP('endCall'),
          QT_TR_NOOP('incomingCall'),
          QT_TR_NOOP('lostIncomingCall'),
          QT_TR_NOOP('lostOutgoingCall')
        ]
      }
    }

    color: ChatStyle.entry.event.text.color
    font {
      bold: true
      pointSize: ChatStyle.entry.event.text.fontSize
    }
    height: parent.height
    text: qsTr(Utils.snakeToCamel($content))
    verticalAlignment: Text.AlignVCenter
  }

  ActionButton {
    height: ChatStyle.entry.lineHeight
    icon: 'delete'
    iconSize: ChatStyle.entry.deleteIconSize
    visible: isHoverEntry()

    onClicked: removeEntry()
  }
}
