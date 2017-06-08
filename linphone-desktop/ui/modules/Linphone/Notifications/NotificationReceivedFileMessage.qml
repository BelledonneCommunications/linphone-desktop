import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Notification {
  id: notification

  // ---------------------------------------------------------------------------

  property string _fileUri: notificationData && notificationData.fileUri || ''

  // ---------------------------------------------------------------------------

  Rectangle {
    color: NotificationReceivedFileMessageStyle.color
    height: NotificationReceivedFileMessageStyle.height
    width: NotificationReceivedFileMessageStyle.width

    Icon {
      anchors {
        left: parent.left
        top: parent.top
      }

      icon: 'file_sign'
      iconSize: NotificationReceivedFileMessageStyle.iconSize
    }

    Loader {
      active: notification._fileUri.length > 0
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
          text: Utils.basename(notification._fileUri)
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
          Qt.openUrlExternally(Utils.getUriFromSystemPath(Utils.dirname(notification._fileUri)))
        })
      }
    }
  }
}
