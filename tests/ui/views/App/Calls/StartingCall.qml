import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

Rectangle {
  property alias callType: callType.text
  property alias sipAddress: contactDescription.sipAddress
  property alias username: contactDescription.username
  property alias avatarImage: image.source

  default property alias _actionArea: actionArea.data

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
        id: callType

        color: '#8E8E8E'
        font.bold: true
        font.pointSize: 17
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
      }

      CaterpillarAnimation {
        anchors.horizontalCenter: parent.horizontalCenter
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
          width: height
        }
      }
    }

    // Actions area.
    Item {
      id: actionArea

      Layout.alignment: Qt.AlignHCenter
      Layout.fillWidth: true
      Layout.preferredHeight: 80
      Layout.topMargin: 20
    }
  }
}
