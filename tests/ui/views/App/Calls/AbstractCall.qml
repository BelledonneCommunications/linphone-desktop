import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0

// ===================================================================

Rectangle {
  id: abstractCall

  default property alias _actionArea: actionArea.data
  property alias callTypeLabel: callType.text
  property bool isOutgoing: false
  property bool isVideoCall: false
  property string sipAddress

  property var _contact: ContactsListModel.mapSipAddressToContact(
    sipAddress
  ) || sipAddress

  // -----------------------------------------------------------------

  color: '#E8E8E8'

  ColumnLayout {
    anchors {
      fill: parent
      topMargin: 26
    }

    spacing: 0

    // ---------------------------------------------------------------
    // Call type.
    // ---------------------------------------------------------------

    Column {
      spacing: 10

      Layout.fillWidth: true

      Text {
        id: callType

        color: '#96A5B1'

        font {
          bold: true
          pointSize: 17
        }

        horizontalAlignment: Text.AlignHCenter
        width: parent.width
      }

      CaterpillarAnimation {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: abstractCall.isOutgoing
      }
    }

    // ---------------------------------------------------------------
    // Contact visual.
    // ---------------------------------------------------------------

    Item {
      id: container

      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.margins: 20

      Item {
        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: contactDescription.height + avatar.height
        width: parent.width

        ContactDescription {
          id: contactDescription

          username: LinphoneUtils.getContactUsername(_contact)
          sipAddress: abstractCall.sipAddress
          height: 60
          horizontalTextAlignment: Text.AlignHCenter
          width: parent.width
        }

        Avatar {
          id: avatar

          function _computeAvatarSize () {
            var height = container.height - contactDescription.height
            var width = container.width

            var size = height < 250 && height > 0 ? height : 250
            return size < width ? size : width
          }

          anchors {
            top: contactDescription.bottom
            horizontalCenter: parent.horizontalCenter
          }

          backgroundColor: '#A1A1A1'
          image: _contact.avatar
          username: contactDescription.username

          height: _computeAvatarSize()
          width: height
        }
      }
    }

    // ---------------------------------------------------------------
    // Buttons.
    // ---------------------------------------------------------------

    Item {
      id: actionArea

      Layout.alignment: Qt.AlignHCenter
      Layout.fillWidth: true
      Layout.preferredHeight: 100
    }
  }
}
