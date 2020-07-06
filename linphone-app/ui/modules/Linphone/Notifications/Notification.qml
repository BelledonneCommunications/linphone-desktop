import QtQuick 2.7

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

DesktopPopup {
  id: notification

  property alias icon: iconSign.icon
  property var notificationData: ({})
  property int overrodeHeight
  default property alias _content: content.data

  signal deleteNotification (var notification)
  
// Use as an intermediate between signal/slot without propagate the notification var : last signal parameter will be the last notification instance
  function deleteNotificationSlot(){
    deleteNotification(notification)
  }

  function _close (cb) {
    if (cb) {
      cb()
    }
    deleteNotificationSlot();
  }

  Rectangle {
    color: NotificationStyle.color
    height: overrodeHeight || NotificationStyle.height
    width: NotificationStyle.width

    border {
      color: NotificationStyle.border.color
      width: NotificationStyle.border.width
    }

    Item {
      id: content

      anchors.fill: parent
    }

    Icon {
      id: iconSign

      anchors {
        left: parent.left
        top: parent.top
      }

      iconSize: NotificationStyle.iconSize
    }
  }
}
