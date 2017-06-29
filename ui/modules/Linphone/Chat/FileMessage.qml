import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Row {
  // ---------------------------------------------------------------------------
  // Avatar if it's an incoming message.
  // ---------------------------------------------------------------------------

  Item {
    height: ChatStyle.entry.lineHeight
    width: ChatStyle.entry.metaWidth

    Component {
      id: avatar

      Avatar {
        height: ChatStyle.entry.message.incoming.avatarSize
        width: ChatStyle.entry.message.incoming.avatarSize

        image: chat.sipAddressObserver.contact ? chat.sipAddressObserver.contact.vcard.avatar : ''
        username: LinphoneUtils.getContactUsername(chat.sipAddressObserver)
      }
    }

    Loader {
      anchors.centerIn: parent
      sourceComponent: !$chatEntry.isOutgoing ? avatar : undefined
    }
  }

  // ---------------------------------------------------------------------------
  // File message.
  // ---------------------------------------------------------------------------

  Row {
    spacing: ChatStyle.entry.message.extraContent.leftMargin

    Rectangle {
      id: rectangle

      readonly property bool isNotDelivered: Utils.includes([
        ChatModel.MessageStatusFileTransferError,
        ChatModel.MessageStatusIdle,
        ChatModel.MessageStatusInProgress,
        ChatModel.MessageStatusNotDelivered
      ], $chatEntry.status)

      readonly property bool isRead: $chatEntry.status === ChatModel.MessageStatusDisplayed

      color: $chatEntry.isOutgoing
        ? ChatStyle.entry.message.outgoing.backgroundColor
        : ChatStyle.entry.message.incoming.backgroundColor

      height: ChatStyle.entry.message.file.height
      width: ChatStyle.entry.message.file.width

      radius: ChatStyle.entry.message.radius

      RowLayout {
        anchors {
          fill: parent
          margins: ChatStyle.entry.message.file.margins
        }

        spacing: ChatStyle.entry.message.file.spacing

        // ---------------------------------------------------------------------
        // Thumbnail or extension.
        // ---------------------------------------------------------------------

        Component {
          id: thumbnail

          Image {
            source: $chatEntry.thumbnail
          }
        }

        Component {
          id: extension

          Rectangle {
            color: ChatStyle.entry.message.file.extension.background.color

            Text {
              anchors.fill: parent

              color: ChatStyle.entry.message.file.extension.text.color
              font.bold: true
              elide: Text.ElideRight
              text: Utils.getExtension($chatEntry.fileName).toUpperCase()

              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }
          }
        }

        Loader {
          id: thumbnailProvider

          Layout.fillHeight: true
          Layout.preferredWidth: parent.height

          sourceComponent: $chatEntry.thumbnail ? thumbnail : extension

          ScaleAnimator {
            id: thumbnailProviderAnimator

            target: thumbnailProvider

            duration: ChatStyle.entry.message.file.animation.duration
            easing.type: Easing.InOutQuad
            from: 1.0
          }

          states: State {
            name: 'hovered'
          }

          transitions: [
            Transition {
              from: ''
              to: 'hovered'

              ScriptAction {
                script: {
                  if (thumbnailProviderAnimator.running) {
                    thumbnailProviderAnimator.running = false
                  }

                  thumbnailProvider.z = Constants.zPopup
                  thumbnailProviderAnimator.to = ChatStyle.entry.message.file.animation.to
                  thumbnailProviderAnimator.running = true
                }
              }
            },
            Transition {
              from: 'hovered'
              to: ''

              ScriptAction {
                script: {
                  if (thumbnailProviderAnimator.running) {
                    thumbnailProviderAnimator.running = false
                  }

                  thumbnailProviderAnimator.to = 1.0
                  thumbnailProviderAnimator.running = true
                  thumbnailProvider.z = 0
                }
              }
            }
          ]
        }

        // ---------------------------------------------------------------------
        // Upload or file status.
        // ---------------------------------------------------------------------

        Column {
          Layout.fillWidth: true
          Layout.fillHeight: true

          spacing: ChatStyle.entry.message.file.status.spacing

          Text {
            id: fileName

            color: $chatEntry.isOutgoing
              ? ChatStyle.entry.message.outgoing.text.color
              : ChatStyle.entry.message.incoming.text.color
            elide: Text.ElideRight

            font {
              bold: true
              pointSize: $chatEntry.isOutgoing
                ? ChatStyle.entry.message.outgoing.text.pointSize
                : ChatStyle.entry.message.incoming.text.pointSize
            }

            text: $chatEntry.fileName
            width: parent.width
          }

          ProgressBar {
            id: progressBar

            height: ChatStyle.entry.message.file.status.bar.height
            width: parent.width

            to: $chatEntry.fileSize
            value: $chatEntry.fileOffset || 0
            visible: $chatEntry.status === ChatModel.MessageStatusInProgress

            background: Rectangle {
              color: ChatStyle.entry.message.file.status.bar.background.color
              radius: ChatStyle.entry.message.file.status.bar.radius
            }

            contentItem: Item {
              Rectangle {
                color: ChatStyle.entry.message.file.status.bar.contentItem.color
                height: parent.height
                width: progressBar.visualPosition * parent.width
              }
            }
          }

          Text {
            color: fileName.color
            elide: Text.ElideRight
            font.pointSize: fileName.font.pointSize
            text: {
              var fileSize = Utils.formatSize($chatEntry.fileSize)
              return progressBar.visible
                ? Utils.formatSize($chatEntry.fileOffset) + '/' + fileSize
                : fileSize
            }
          }
        }
      }

      Icon {
        anchors {
          bottom: parent.bottom
          bottomMargin: ChatStyle.entry.message.file.margins
          right: parent.right
          rightMargin: ChatStyle.entry.message.file.margins
        }

        icon: 'download'
        iconSize: ChatStyle.entry.message.file.iconSize
        visible: !$chatEntry.isOutgoing && !$chatEntry.wasDownloaded
      }

      MouseArea {
        function handleMouseMove (mouse) {
          thumbnailProvider.state = Utils.pointIsInItem(this, thumbnailProvider, mouse)
            ? 'hovered'
            : ''
        }

        anchors.fill: parent
        cursorShape: containsMouse
          ? Qt.PointingHandCursor
          : Qt.ArrowCursor
        hoverEnabled: true
        visible: !rectangle.isNotDelivered && !$chatEntry.isOutgoing

        onClicked: {
          if (Utils.pointIsInItem(this, thumbnailProvider, mouse)) {
            proxyModel.openFile(index)
          } else if ($chatEntry.wasDownloaded) {
            proxyModel.openFileDirectory(index)
          } else  {
            proxyModel.downloadFile(index)
          }
        }

        onExited: thumbnailProvider.state = ''
        onMouseXChanged: handleMouseMove.call(this, mouse)
        onMouseYChanged: handleMouseMove.call(this, mouse)
      }
    }

    // -------------------------------------------------------------------------
    // Resend/Remove file message.
    // -------------------------------------------------------------------------

    Row {
      spacing: ChatStyle.entry.message.extraContent.spacing

      Component {
        id: icon

        Icon {
          icon: rectangle.isNotDelivered
            ? 'chat_error'
            : (rectangle.isRead ? 'chat_read' : 'chat_delivered')

          iconSize: ChatStyle.entry.message.outgoing.sendIconSize

          MouseArea {
            anchors.fill: parent
            onClicked: isNotDelivered && proxyModel.resendMessage(index)
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

        sourceComponent: $chatEntry.isOutgoing
          ? (
            $chatEntry.status === ChatModel.MessageStatusInProgress
              ? indicator
              : icon
          ) : undefined
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
