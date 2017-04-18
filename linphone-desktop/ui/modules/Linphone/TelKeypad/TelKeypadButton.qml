import QtQuick 2.7
import QtQuick.Controls 2.0

import Linphone.Styles 1.0

// =============================================================================

Item {
  id: button

  property string icon: ''
  property string text: ''

  signal clicked

  // ---------------------------------------------------------------------------

  Button {
    anchors.fill: parent

    background: Rectangle {
      color: TelKeypadStyle.button.color.normal
    }

    contentItem: Text {
      color: TelKeypadStyle.button.text.color

      font {
        bold: true
        pointSize: TelKeypadStyle.button.text.fontSize
      }

      elide: Text.ElideRight
      text: button.text

      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }

    hoverEnabled: true

    onClicked: button.clicked()
  }
}
