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
  readonly property string imageUri: notificationData && notificationData.imageUri || ''

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
        visible:!image.visible
      }
      Image{
        id:image
        mipmap: Qt.platform.os === 'osx'
        Layout.fillHeight: true
        Layout.fillWidth: true
        fillMode: Image.PreserveAspectFit
        source: (imageUri ?"image://external/"+notification.imageUri : '')
        visible: image.status == Image.Ready
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

      onClicked: notification._close(function () {
        var uri = Utils.getUriFromSystemPath(notification.fileUri)
        if (!Qt.openUrlExternally(uri)) {
          Qt.openUrlExternally(Utils.dirname(uri))
        }
      })
    }
  }
}
