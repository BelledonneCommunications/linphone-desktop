import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Item {
  implicitHeight: message.height
  width: parent.width

  Message {
    id: message

    anchors {
      left: parent.left
      leftMargin: ChatStyle.entry.metaWidth
      right: parent.right
    }
    backgroundColor: ChatStyle.entry.message.outgoing.backgroundColor
    color: ChatStyle.entry.message.outgoing.text.color
    pointSize: ChatStyle.entry.message.outgoing.text.pointSize
    width: parent.width

    Row {
      spacing: ChatStyle.entry.message.extraContent.spacing

      Component {
        id: iconComponent

        Icon {
          id: iconId
          readonly property var isError: Utils.includes([
                ChatModel.MessageStatusFileTransferError,
                ChatModel.MessageStatusNotDelivered,
                ], $chatEntry.status)
          readonly property bool isUploaded: $chatEntry.status === ChatModel.MessageStatusDelivered
          readonly property bool isDelivered: $chatEntry.status === ChatModel.MessageStatusDeliveredToUser
          readonly property bool isRead: $chatEntry.status === ChatModel.MessageStatusDisplayed

          icon: isError
            ? 'chat_error'
            : (isRead ? 'chat_read' : (isDelivered ? 'chat_delivered' : ''))
          iconSize: ChatStyle.entry.message.outgoing.sendIconSize

          MouseArea {
            id:retryAction
            anchors.fill: parent
            visible: iconId.isError || $chatEntry.status === ChatModel.MessageStatusIdle
            onClicked: proxyModel.resendMessage(index)
          }

          TooltipArea {
            id:tooltip
            text: iconId.isError
              ? qsTr('messageError')
              : (isRead ? qsTr('messageRead') : qsTr('messageDelivered'))
              hoveringCursor : retryAction.visible?Qt.PointingHandCursor:Qt.ArrowCursor
          }
        }
      }

      Component {
        id: indicator

        Item {
          anchors.fill: parent

          BusyIndicator {
            anchors.centerIn: parent

            height: ChatStyle.entry.message.outgoing.busyIndicatorSize
            width: ChatStyle.entry.message.outgoing.busyIndicatorSize
          }
        }
      }

      Loader {
        height: ChatStyle.entry.lineHeight
        width: ChatStyle.entry.message.outgoing.areaSize

        sourceComponent: $chatEntry.status === ChatModel.MessageStatusInProgress || $chatEntry.status === ChatModel.MessageStatusFileTransferInProgress
          ? indicator
          : iconComponent
      }

      ActionButton {
        height: ChatStyle.entry.lineHeight
        icon: 'delete'
        iconSize: ChatStyle.entry.deleteIconSize
        visible: isHoverEntry()

        onClicked: removeEntry()
      }
    }
  }
}
