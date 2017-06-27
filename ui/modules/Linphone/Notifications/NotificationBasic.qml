import QtQuick 2.7

import Common 1.0
import Linphone.Styles 1.0

// =============================================================================

Notification {
  id: notification

  property string message
  property var handler: (function () {})

  overrodeHeight: NotificationBasicStyle.overrodeHeight

  // ---------------------------------------------------------------------------

  Loader {
    active: Boolean(notification.message)
    anchors {
      fill: parent

      leftMargin: NotificationBasicStyle.leftMargin
      rightMargin: NotificationBasicStyle.rightMargin
    }

    sourceComponent: Text {
      anchors.fill: parent

      color: NotificationBasicStyle.message.color
      font.pointSize: NotificationBasicStyle.message.pointSize
      text: notification.message
      verticalAlignment: Text.AlignVCenter
      wrapMode: Text.Wrap

      MouseArea {
        anchors.fill: parent
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        hoverEnabled: true

        onClicked: notification._close(notification.handler)
      }
    }
  }
}
