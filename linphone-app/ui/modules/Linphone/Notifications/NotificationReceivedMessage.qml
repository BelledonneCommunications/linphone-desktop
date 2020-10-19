import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Notification {
  id: notification

  icon: 'message_sign'

  // ---------------------------------------------------------------------------

  readonly property string peerAddress: notificationData && notificationData.peerAddress ||  ''
  readonly property string localAddress: notificationData && notificationData.localAddress || ''
  readonly property string fullPeerAddress: notificationData && notificationData.fullPeerAddress ||  ''
  readonly property string fullLocalAddress: notificationData && notificationData.fullLocalAddress || ''

  // ---------------------------------------------------------------------------

  Loader {
    active: Boolean(notification.peerAddress) && Boolean(notification.localAddress)
    anchors {
      fill: parent

      leftMargin: NotificationReceivedMessageStyle.leftMargin
      rightMargin: NotificationReceivedMessageStyle.rightMargin
      bottomMargin: NotificationReceivedMessageStyle.bottomMargin
    }

    sourceComponent: ColumnLayout {
      spacing: NotificationReceivedMessageStyle.spacing

      Contact {
        Layout.fillWidth: true

        entry: SipAddressesModel.getSipAddressObserver(notification.fullPeerAddress, notification.fullLocalAddress)
      }

      Rectangle {
        Layout.fillHeight: true
        Layout.fillWidth: true

        color: NotificationReceivedMessageStyle.messageContainer.color
        radius: NotificationReceivedMessageStyle.messageContainer.radius

        Text {
          anchors {
            fill: parent
            margins: NotificationReceivedMessageStyle.messageContainer.margins
          }

          color: NotificationReceivedMessageStyle.messageContainer.text.color
          elide: Text.ElideRight

          font {
            italic: true
            pointSize: NotificationReceivedMessageStyle.messageContainer.text.pointSize
          }

          verticalAlignment: Text.AlignVCenter
          text: notification.notificationData.message
          wrapMode: Text.Wrap
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent

    onClicked: notification._close(function () {
      AccountSettingsModel.setDefaultProxyConfigFromSipAddress(notification.localAddress)
      notification.notificationData.window.setView('Conversation', {
        peerAddress: notification.peerAddress,
        localAddress: notification.localAddress,
        fullPeerAddress: notification.fullPeerAddress,
        fullLocalAddress: notification.fullLocalAddress
      })
    })
  }
}
