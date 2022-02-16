import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Item {
  implicitHeight: message.height
  //width: parent.width
  Layout.fillWidth: true
  
  signal copyAllDone()
  signal copySelectionDone()
  signal replyClicked()
  signal forwardClicked()
  signal goToMessage(ChatMessageModel message)

  Message {
    id: message
    
	onCopyAllDone: parent.copyAllDone()
	onCopySelectionDone: parent.copySelectionDone()
	onReplyClicked: parent.replyClicked()
	onForwardClicked: parent.forwardClicked()
	onGoToMessage: parent.goToMessage(message)
	
    anchors {
      left: parent.left
      leftMargin: ChatStyle.entry.metaWidth
      right: parent.right
    }
    backgroundColor: ChatStyle.entry.message.outgoing.backgroundColor
    width: parent.width

    Row {
      spacing: ChatStyle.entry.message.extraContent.spacing

      Component {
        id: iconComponent

        Icon {
          id: iconId
          readonly property var isError: Utils.includes([
                LinphoneEnums.ChatMessageStateFileTransferError,
                LinphoneEnums.ChatMessageStateNotDelivered,
                ], $chatEntry.state)
          readonly property bool isUploaded: $chatEntry.state == LinphoneEnums.ChatMessageStateDelivered
          readonly property bool isDelivered: $chatEntry.state == LinphoneEnums.ChatMessageStateDeliveredToUser
          readonly property bool isRead: $chatEntry.state == LinphoneEnums.ChatMessageStateDisplayed

          icon: iconId.isError
            ? 'chat_error'
            : (iconId.isRead ? 'chat_read' : (iconId.isDelivered  ? 'chat_delivered' : '' ) )
          iconSize: ChatStyle.entry.message.outgoing.sendIconSize

          MouseArea {
            id:retryAction
            anchors.fill: parent
            visible: iconId.isError || $chatEntry.state == LinphoneEnums.ChatMessageStateIdle
            onClicked: $chatEntry.resendMessage()
          }

          TooltipArea {
            id:tooltip
            visible: text != ''
            text: iconId.isError
              ? qsTr('messageError')
              : (iconId.isRead ? qsTr('messageRead') : (isDelivered ? qsTr('messageDelivered') : ''))
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

        sourceComponent: $chatEntry.state == LinphoneEnums.ChatMessageStateInProgress || $chatEntry.state == LinphoneEnums.ChatMessageStateFileTransferInProgress
          ? indicator
          : iconComponent
      }
    }
  }
}
