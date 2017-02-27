import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Notification {
  id: notification

  // ---------------------------------------------------------------------------

  property var _call: notificationData && notificationData.call
  property var _contact: _contactObserver.contact
  property var _contactObserver: SipAddressesModel.getContactObserver(_call ? _call.sipAddress : '')

  // ---------------------------------------------------------------------------

  Rectangle {
    color: NotificationReceivedCallStyle.color
    height: NotificationReceivedCallStyle.height
    width: NotificationReceivedCallStyle.width

    Icon {
      anchors {
        left: parent.left
        top: parent.top
      }

      icon: 'call_sign_incoming'
      iconSize: NotificationReceivedCallStyle.iconSize
    }

    Loader {
      active: Boolean(notification._call)
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

          entry: ({
            contact: notification._contact,
            sipAddress: notification._contactObserver.sipAddress
          })
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

              onClicked: notification._close(notification._call.acceptWithVideo)
            }

            ActionButton {
              icon: 'call_accept'

              onClicked: notification._close(notification._call.accept)
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

              onClicked: notification._close(notification._call.terminate)
            }
          }
        }
      }
    }
  }
}
