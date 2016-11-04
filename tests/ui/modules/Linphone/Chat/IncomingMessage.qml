import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// ===================================================================

RowLayout {
  implicitHeight: message.height
  spacing: 0

  Item {
    Layout.alignment: Qt.AlignTop
    Layout.preferredHeight: ChatStyle.entry.lineHeight
    Layout.preferredWidth: ChatStyle.entry.metaWidth

    Avatar {
      anchors.centerIn: parent
      username: contact.username
      width: ChatStyle.entry.lineHeight
      height: ChatStyle.entry.lineHeight
    }
  }

  Message {
    id: message

    Layout.fillWidth: true

    // Not a style. Workaround to avoid a 0 width.
    // Arbitrary value.
    Layout.minimumWidth: 20

    backgroundColor: ChatStyle.entry.message.incoming.backgroundColor
    color: ChatStyle.entry.message.incoming.text.color
    fontSize: ChatStyle.entry.message.incoming.text.fontSize

    ActionButton {
      height: ChatStyle.entry.lineHeight
      icon: 'delete'
      iconSize: ChatStyle.entry.deleteIconSize
      visible: isHoverEntry()

      onClicked: deleteEntry()
    }
  }
}
