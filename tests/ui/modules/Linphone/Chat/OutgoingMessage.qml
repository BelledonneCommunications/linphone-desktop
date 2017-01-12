import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

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

        Icon {
          property bool isNotDelivered: $chatEntry.status === ChatModel.MessageStatusNotDelivered

          icon: isNotDelivered ? 'chat_error' : 'chat_send'
          iconSize: ChatStyle.entry.message.outgoing.sendIconSize

          MouseArea {
            anchors.fill: parent
            onClicked: isNotDelivered && proxyModel.resendMessage(index)
          }
        }
      }

      Component {
        id: indicator
        BusyIndicator {
          width: ChatStyle.entry.message.outgoing.sendIconSize
        }
      }

      Loader {
        height: ChatStyle.entry.lineHeight
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
