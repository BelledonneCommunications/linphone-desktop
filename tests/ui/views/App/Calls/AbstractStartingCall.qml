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
  property var _contactObserver: SipAddressesModel.getContactObserver(sipAddress)

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

        height: CallStyle.contactDescriptionHeight
        horizontalTextAlignment: Text.AlignHCenter
        sipAddress: call.sipAddress
        username: LinphoneUtils.getContactUsername(_contactObserver.contact || call.sipAddress)
        width: parent.width
      }

      BusyIndicator {
        anchors.horizontalCenter: parent.horizontalCenter
        color: CallStyle.busyIndicator.color
        height: CallStyle.busyIndicator.height
        width: CallStyle.busyIndicator.width

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
      Layout.margins: CallStyle.containerMargins

      Avatar {
        id: avatar

        function _computeAvatarSize () {
          var height = container.height
          var width = container.width

          var size = height < CallStyle.avatar.maxSize && height > 0
              ? height
              : CallStyle.avatar.maxSize
          return size < width ? size : width
        }

        anchors.centerIn: parent
        backgroundColor: CallStyle.avatar.backgroundColor
        image: _contactObserver.contact && _contactObserver.contact.avatar
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
      Layout.preferredHeight: CallStyle.actionAreaHeight
    }
  }
}
