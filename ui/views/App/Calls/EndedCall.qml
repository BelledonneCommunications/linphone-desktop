import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone 1.0
import LinphoneUtils 1.0
import Utils 1.0

import App.Styles 1.0

import 'Incall.js' as Logic

// =============================================================================

Rectangle {
  id: endedCall

  property var call

  property var _sipAddressObserver: SipAddressesModel.getSipAddressObserver(sipAddress)

  // ---------------------------------------------------------------------------

  color: CallStyle.backgroundColor

  ColumnLayout {
    anchors {
      fill: parent
      topMargin: CallStyle.header.topMargin
    }

    spacing: 0

    ContactDescription {
      id: contactDescription

      Layout.fillWidth: true
      Layout.preferredHeight: CallStyle.header.contactDescription.height

      horizontalTextAlignment: Text.AlignHCenter
      sipAddress: _sipAddressObserver.sipAddress
      username: LinphoneUtils.getContactUsername(_sipAddressObserver)
    }

    Text {
      Layout.fillWidth: true

      color: CallStyle.header.elapsedTime.color
      font.pointSize: CallStyle.header.elapsedTime.pointSize
      horizontalAlignment: Text.AlignHCenter

      text: {
        var call = endedCall.call
        return call ? Utils.formatElapsedTime(call.duration) : 0
      }
    }

    Item {
      id: container

      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.margins: CallStyle.container.margins

      Avatar {
        anchors.centerIn: parent
        backgroundColor: CallStyle.container.avatar.backgroundColor
        image: _sipAddressObserver.contact && _sipAddressObserver.contact.vcard.avatar
        username: contactDescription.username

        height: Logic.computeAvatarSize(CallStyle.container.avatar.maxSize)
        width: height
      }
    }

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: CallStyle.actionArea.height

      Text {
        color: CallStyle.actionArea.callError.color
        font.pointSize: CallStyle.actionArea.callError.pointSize
        horizontalAlignment: Text.AlignHCenter
        width: parent.width

        text: {
          var call = endedCall.call
          return call ? call.callError : ''
        }
      }
    }
  }
}
