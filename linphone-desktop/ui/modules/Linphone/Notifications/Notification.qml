import QtQuick 2.7

import Common 1.0

// =============================================================================

DesktopPopup {
  id: notification

  property var notificationData: ({})

  signal deleteNotification (var notification)

  function _close (cb) {
    if (cb) {
      cb()
    }

    deleteNotification(notification)
  }

  flags: {
    return (Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint) &
      (Qt.platform.os === 'osx' ? Qt.Window : Qt.Tool)
  }
}
