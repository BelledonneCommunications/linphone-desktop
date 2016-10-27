import QtQuick 2.7
import QtQuick.Controls 2.0

import Common 1.0
import Linphone 1.0

DialogPlus {
  centeredButtons: true
  minimumHeight: 300
  minimumWidth: 420
  title: qsTr('newCallTitle')

  buttons: TextButtonA {
    text: qsTr('cancel')
  }

  Item {
    anchors.fill: parent
    anchors.leftMargin: 25
    anchors.rightMargin: 25

    SelectContact {
      anchors.fill: parent
    }
  }
}
