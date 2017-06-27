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

  function _close (cb) {
    if (cb) {
      cb()
    }

    deleteNotification(notification)
  }

  flags: {
    return (Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint) |
      (Qt.platform.os === 'osx' ? Qt.Window : Qt.Popup)
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
