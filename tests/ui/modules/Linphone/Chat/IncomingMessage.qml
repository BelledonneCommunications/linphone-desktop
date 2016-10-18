import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone 1.0

// ===================================================================

RowLayout {
  implicitHeight: message.height
  spacing: 10

  Avatar {
    Layout.alignment: Qt.AlignTop
    Layout.preferredHeight: 30
    Layout.preferredWidth: 30
  }

  Message {
    id: message

    Layout.fillWidth: true
    backgroundColor: '#BFBFBF'
  }
}
