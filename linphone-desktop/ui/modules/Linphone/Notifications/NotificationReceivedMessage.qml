import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Notification {
  id: notification

  // ---------------------------------------------------------------------------

  property string _sipAddress: notificationData && notificationData.sipAddress || ''
  property var _contact: _contactObserver.contact
  property var _contactObserver: SipAddressesModel.getContactObserver(_sipAddress)

  // ---------------------------------------------------------------------------

  Rectangle {
    color: NotificationReceivedMessageStyle.color
    height: NotificationReceivedMessageStyle.height
    width: NotificationReceivedMessageStyle.width

    Icon {
      anchors {
        left: parent.left
        top: parent.top
      }

      icon: 'message_sign'
      iconSize: NotificationReceivedMessageStyle.iconSize
    }

    Loader {
      active: notification._sipAddress.length > 0
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

          entry: ({
            contact: notification._contact,
            sipAddress: notification._sipAddress
          })
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
              pointSize: NotificationReceivedMessageStyle.messageContainer.text.fontSize
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
      cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
      hoverEnabled: true

      onClicked: {
        notification.window.setVisible(false)
        notification.notificationData.window.setView('Conversation', {
          sipAddress: notification._sipAddress
        })
      }
    }
  }
}
