import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import App.Styles 1.0

// =============================================================================

Rectangle {
  property var call

  default property alias _actionArea: actionArea.data
  property var _sipAddressObserver: SipAddressesModel.getSipAddressObserver(sipAddress)

  // ---------------------------------------------------------------------------

  color: CallStyle.backgroundColor

  ColumnLayout {
    anchors {
      fill: parent
      topMargin: CallStyle.header.topMargin
    }

    spacing: 0

    // -------------------------------------------------------------------------
    // Contact & Call type (animation).
    // -------------------------------------------------------------------------

    Column {
      Layout.fillWidth: true
      spacing: CallStyle.header.spacing

      ContactDescription {
        id: contactDescription

        height: CallStyle.header.contactDescription.height
        horizontalTextAlignment: Text.AlignHCenter
        sipAddress: call.sipAddress
        username: LinphoneUtils.getContactUsername(_sipAddressObserver)
        width: parent.width
      }

      BusyIndicator {
        anchors.horizontalCenter: parent.horizontalCenter
        color: CallStyle.header.busyIndicator.color
        height: CallStyle.header.busyIndicator.height
        width: CallStyle.header.busyIndicator.width

        visible: call.isOutgoing
      }
    }

    // -------------------------------------------------------------------------
    // Contact visual.
    // -------------------------------------------------------------------------

    Item {
      id: container

      Layout.fillHeight: true
      Layout.fillWidth: true
      Layout.margins: CallStyle.container.margins

      Avatar {
        id: avatar

        function _computeAvatarSize () {
          var height = container.height
          var width = container.width

          var size = height < CallStyle.container.avatar.maxSize && height > 0
            ? height
            : CallStyle.container.avatar.maxSize
          return size < width ? size : width
        }

        anchors.centerIn: parent
        backgroundColor: CallStyle.container.avatar.backgroundColor
        image: _sipAddressObserver.contact && _sipAddressObserver.contact.vcard.avatar
        username: contactDescription.username

        height: _computeAvatarSize()
        width: height
      }
    }

    // -------------------------------------------------------------------------
    // Buttons.
    // -------------------------------------------------------------------------

    Item {
      id: actionArea

      Layout.fillWidth: true
      Layout.preferredHeight: CallStyle.actionArea.height
    }
  }
}
