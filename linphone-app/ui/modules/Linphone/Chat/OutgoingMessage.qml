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
        id: icon

        Icon {
          readonly property bool isNotDelivered: Utils.includes([
            ChatModel.MessageStatusFileTransferError,
            ChatModel.MessageStatusIdle,
            ChatModel.MessageStatusInProgress,
            ChatModel.MessageStatusNotDelivered
          ], $chatEntry.status)

          readonly property bool isRead: $chatEntry.status === ChatModel.MessageStatusDisplayed
          readonly property bool isDeliveredToUser: $chatEntry.status === ChatModel.MessageStatusDeliveredToUser

          icon: isNotDelivered
            ? 'chat_error'
            : (isRead ? 'chat_read' : (isDeliveredToUser ? 'chat_delivered' : ''))
          iconSize: ChatStyle.entry.message.outgoing.sendIconSize

          MouseArea {
            anchors.fill: parent
            onClicked: isNotDelivered && proxyModel.resendMessage(index)
          }

          TooltipArea {
            text: isNotDelivered
              ? qsTr('messageError')
              : (isRead ? qsTr('messageRead') : qsTr('messageDelivered'))
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

        sourceComponent: $chatEntry.status === ChatModel.MessageStatusInProgress
          ? indicator
          : icon
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
