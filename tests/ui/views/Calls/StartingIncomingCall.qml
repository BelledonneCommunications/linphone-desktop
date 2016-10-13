import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone 1.0

Rectangle {
  color: '#EAEAEA'

  ColumnLayout {
    anchors {
      fill: parent
      margins: 20
    }

    spacing: 0

    // Call type.
    Column {
      Layout.fillWidth: true

      Text {
        color: '#8E8E8E'
        font.bold: true
        font.pointSize: 17
        horizontalAlignment: Text.AlignHCenter
        text: 'INCOMING CALL'
        width: parent.width
      }

      Text {
        color: '#8E8E8E'
        font.bold: true
        font.pointSize: 17
        horizontalAlignment: Text.AlignHCenter
        text: '...'
        width: parent.width
      }
    }

    // Contact area.
    Item {
      id: contactContainer

      Layout.fillWidth: true
      Layout.fillHeight: true

      Item {
        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: contactDescription.height + image.height
        width: parent.width

        ContactDescription {
          id: contactDescription

          height: 60
          horizontalTextAlignment: Text.AlignHCenter
          sipAddress: 'mister-meow@sip-linphone.org'
          username: 'Mister Meow'
          width: parent.width
        }

        RoundedImage {
          id: image

          function _computeImageSize () {
            var height = contactContainer.height - contactDescription.height
            var width = contactContainer.width

            var size = height < 400 ? height : 400
            return size < width ? size : width
          }

          anchors.top: contactDescription.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          height: _computeImageSize()
          source: "qrc:/imgs/cat_contact.jpg"
          width: height
        }
      }
    }

    // Actions area.
    ActionBar {
      Layout.alignment: Qt.AlignHCenter
      Layout.bottomMargin: 20
      Layout.topMargin: 20
      iconSize: 40

      ActionButton {
        icon: 'cam'
      }

      ActionButton {
        icon: 'call'
      }

      ActionButton {
        icon: 'hangup'
      }
    }
  }
}
