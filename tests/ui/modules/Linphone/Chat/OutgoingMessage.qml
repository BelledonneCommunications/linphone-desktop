import QtQuick 2.7

import Common 1.0
import Linphone 1.0

Item {
  implicitHeight: message.height
  width: parent.width - 16

  Message {
    id: message

    anchors {
      left: parent.left
      right: parent.right
    }

    backgroundColor: '#E4E4E4'

    // TODO: Success and re-send icon.
    Icon {
      iconSize: 16
      icon: 'valid'
    }
  }
}
