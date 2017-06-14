import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone.Styles 1.0

// =============================================================================

Item {
  id: button

  property color color: TelKeypadStyle.button.color.normal
  property string icon: ''
  property string text: ''

  signal clicked

  // ---------------------------------------------------------------------------

  Rectangle {
    anchors.fill: parent
    color: button.color

    ColumnLayout {
      anchors.fill: parent

      spacing: 0

      Text {
        Layout.fillHeight: true
        Layout.fillWidth: true

        color: TelKeypadStyle.button.text.color
        elide: Text.ElideRight

        font {
          bold: true
          pointSize: TelKeypadStyle.button.text.pointSize
        }

        text: button.text

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: TelKeypadStyle.button.line.height

        Layout.bottomMargin: TelKeypadStyle.button.line.bottomMargin
        Layout.leftMargin: TelKeypadStyle.button.line.leftMargin
        Layout.rightMargin: TelKeypadStyle.button.line.rightMargin
        Layout.topMargin: TelKeypadStyle.button.line.topMargin

        color: TelKeypadStyle.button.line.color
      }
    }
  }
}
