import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Notification {
  id: notification

  icon: 'file_sign'
  overrodeHeight: NotificationReceivedFileMessageStyle.overrodeHeight

  // ---------------------------------------------------------------------------

  readonly property string fileUri: notificationData && notificationData.fileUri || ''

  // ---------------------------------------------------------------------------

  Loader {
    active: Boolean(notification.fileUri)
    anchors {
      fill: parent

      leftMargin: NotificationReceivedFileMessageStyle.leftMargin
      rightMargin: NotificationReceivedFileMessageStyle.rightMargin
    }

    sourceComponent: RowLayout {
      anchors.fill: parent
      spacing: NotificationReceivedFileMessageStyle.spacing

      Text {
        Layout.fillWidth: true

        color: NotificationReceivedFileMessageStyle.fileName.color
        elide: Text.ElideRight
        font.pointSize: NotificationReceivedFileMessageStyle.fileName.pointSize
        text: Utils.basename(notification.fileUri)
      }

      Text {
        Layout.preferredWidth: NotificationReceivedFileMessageStyle.fileSize.width

        color: NotificationReceivedFileMessageStyle.fileSize.color
        elide: Text.ElideRight
        font.pointSize: NotificationReceivedFileMessageStyle.fileSize.pointSize
        horizontalAlignment: Text.AlignRight
        text: Utils.formatSize(notification.notificationData.fileSize)
      }
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
      hoverEnabled: true

      onClicked: notification._close(function () {
        var uri = Utils.getUriFromSystemPath(notification.fileUri)
        if (!Qt.openUrlExternally(uri)) {
          Qt.openUrlExternally(Utils.dirname(uri))
        }
      })
    }
  }
}
