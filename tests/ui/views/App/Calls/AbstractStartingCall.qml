import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import App.Styles 1.0

// ===================================================================

Rectangle {
  id: abstractCall

  default property alias _actionArea: actionArea.data
  property alias callTypeLabel: callType.text
  property bool isOutgoing: false
  property bool isVideoCall: false
  property string sipAddress

  property var _contact: SipAddressesModel.mapSipAddressToContact(
    sipAddress
  ) || sipAddress

  // -----------------------------------------------------------------

  color: StartingCallStyle.backgroundColor

  ColumnLayout {
    anchors {
      fill: parent
      topMargin: StartingCallStyle.header.topMargin
    }

    spacing: 0

    // ---------------------------------------------------------------
    // Call type.
    // ---------------------------------------------------------------

    Column {
      Layout.fillWidth: true
      spacing: StartingCallStyle.header.spacing

      Text {
        id: callType

        color: StartingCallStyle.callType.color

        font {
          bold: true
          pointSize: StartingCallStyle.callType.fontSize
        }

        horizontalAlignment: Text.AlignHCenter
        width: parent.width
      }

      CaterpillarAnimation {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: abstractCall.isOutgoing
      }

      ContactDescription {
        id: contactDescription

        height: StartingCallStyle.contactDescriptionHeight
        horizontalTextAlignment: Text.AlignHCenter
        sipAddress: abstractCall.sipAddress
        username: LinphoneUtils.getContactUsername(_contact)
        width: parent.width
      }
    }

    // ---------------------------------------------------------------
    // Contact visual.
    // ---------------------------------------------------------------

    Item {
      id: container

      Layout.fillHeight: true
      Layout.fillWidth: true
      Layout.margins: StartingCallStyle.containerMargins

      Avatar {
        id: avatar

        function _computeAvatarSize () {
          var height = container.height
          var width = container.width

          var size = height < StartingCallStyle.avatar.maxSize && height > 0
              ? height
              : StartingCallStyle.avatar.maxSize
          return size < width ? size : width
        }

        anchors.centerIn: parent
        backgroundColor: StartingCallStyle.avatar.backgroundColor
        image: _contact.avatar
        username: contactDescription.username

        height: _computeAvatarSize()
        width: height
      }
    }

    // ---------------------------------------------------------------
    // Buttons.
    // ---------------------------------------------------------------

    Item {
      id: actionArea

      Layout.fillWidth: true
      Layout.preferredHeight: StartingCallStyle.actionAreaHeight
    }
  }
}
