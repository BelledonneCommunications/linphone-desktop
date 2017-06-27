import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Notification {
  id: notification

  icon: 'call_sign_incoming'

  // ---------------------------------------------------------------------------

  readonly property var call: notificationData && notificationData.call

  // ---------------------------------------------------------------------------

  Loader {
    active: Boolean(notification.call)
    anchors {
      fill: parent

      leftMargin: NotificationReceivedCallStyle.leftMargin
      rightMargin: NotificationReceivedCallStyle.rightMargin
      bottomMargin: NotificationReceivedCallStyle.bottomMargin
    }

    sourceComponent: ColumnLayout {
      spacing: NotificationReceivedCallStyle.spacing

      Contact {
        Layout.fillWidth: true

        entry: {
          var call = notification.call
          return SipAddressesModel.getSipAddressObserver(call ? call.sipAddress : '')
        }
      }

      // ---------------------------------------------------------------------
      // Action buttons.
      // ---------------------------------------------------------------------

      Item {
        Layout.fillHeight: true
        Layout.fillWidth: true

        ActionBar {
          anchors.centerIn: parent
          iconSize: NotificationReceivedCallStyle.actionArea.iconSize

          ActionButton {
            icon: 'video_call_accept'

            onClicked: notification._close(notification.call.acceptWithVideo)
          }

          ActionButton {
            icon: 'call_accept'

            onClicked: notification._close(notification.call.accept)
          }
        }

        ActionBar {
          anchors {
            right: parent.right
            rightMargin: NotificationReceivedCallStyle.actionArea.rightButtonsGroupMargin
            verticalCenter: parent.verticalCenter
          }
          iconSize: NotificationReceivedCallStyle.actionArea.iconSize

          ActionButton {
            icon: 'hangup'

            onClicked: notification._close(notification.call.terminate)
          }
        }
      }
    }
  }
}
