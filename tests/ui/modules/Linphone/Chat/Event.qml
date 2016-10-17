import QtQuick 2.7

import Utils 1.0

// ===================================================================

Text {
  Component {
    // Never created.
    // Private data for `lupdate`.
    Item {
      property var i18n: [
        QT_TR_NOOP('hangup'),
        QT_TR_NOOP('incomingCall'),
        QT_TR_NOOP('lostIncomingCall'),
        QT_TR_NOOP('lostOutgoingCall')
      ]
    }
  }

  color: '#898989'
  font.bold: true
  text: qsTr(Utils.snakeToCamel($content))
}
