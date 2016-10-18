import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

RowLayout {
  implicitHeight: message.height
  spacing: 10

  Message {
    id: message

    Layout.fillWidth: true

    // Not a style. Workaround to avoid a 0 width.
    Layout.minimumWidth: 20

    backgroundColor: '#E4E4E4'
  }

  // TODO: Success and re-send icon.
  Icon {
    Layout.alignment: Qt.AlignTop
    Layout.preferredHeight: 16
    Layout.preferredWidth: 16

    icon: 'valid'
  }
}
