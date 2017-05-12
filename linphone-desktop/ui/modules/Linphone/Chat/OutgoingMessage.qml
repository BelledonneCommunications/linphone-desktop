import QtQuick 2.7
import QtQuick.Controls 2.0
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
    fontSize: ChatStyle.entry.message.outgoing.text.fontSize
    width: parent.width

    Row {
      spacing: ChatStyle.entry.message.extraContent.spacing

      Component {
        id: icon

        RowLayout {
          Text {
            property bool isNotDelivered: Utils.includes([
              ChatModel.MessageStatusFileTransferError,
              ChatModel.MessageStatusIdle,
              ChatModel.MessageStatusInProgress,
              ChatModel.MessageStatusNotDelivered
            ], $chatEntry.status)

            property bool isRead: Utils.includes([
              ChatModel.MessageStatusDisplayed
            ], $chatEntry.status)

            text: isNotDelivered ? qsTr("Error") : isRead ? qsTr("Read") : qsTr("Delivered")
            color: isNotDelivered ? Colors.error : isRead ? Colors.read : Colors.delivered
            font.pointSize: ChatStyle.entry.message.outgoing.fontSize
          }

          Icon {
            property bool isNotDelivered: Utils.includes([
              ChatModel.MessageStatusFileTransferError,
              ChatModel.MessageStatusIdle,
              ChatModel.MessageStatusInProgress,
              ChatModel.MessageStatusNotDelivered
            ], $chatEntry.status)

            property bool isRead: Utils.includes([
              ChatModel.MessageStatusDisplayed
            ], $chatEntry.status)

            icon: isNotDelivered ? 'chat_error' : isRead ? 'chat_read' : 'chat_delivered'
            iconSize: ChatStyle.entry.message.outgoing.sendIconSize

            MouseArea {
              anchors.fill: parent
              onClicked: isNotDelivered && proxyModel.resendMessage(index)
            }
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

      Component {
        id: indicator
        BusyIndicator {}
      }

      Loader {
        height: ChatStyle.entry.lineHeight
        width: ChatStyle.entry.message.outgoing.sendIconSize

        sourceComponent: $chatEntry.status === ChatModel.MessageStatusInProgress
          ? indicator
          : icon
      }
    }
  }
}
