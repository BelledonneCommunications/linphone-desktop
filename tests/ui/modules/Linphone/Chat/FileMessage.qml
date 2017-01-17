import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
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

        image: _contactObserver.contact ? _contactObserver.contact.avatar : ''
        username: LinphoneUtils.getContactUsername(_contactObserver.contact || proxyModel.sipAddress)
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
            color: Colors.l50

            Text {
              anchors.fill: parent

              color: Colors.k
              font.bold: true
              elide: Text.ElideRight
              text: Utils.getExtension($chatEntry.fileName).toUpperCase()

              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }
          }
        }

        Loader {
          Layout.preferredHeight: ChatStyle.entry.message.file.thumbnail.height
          Layout.preferredWidth: ChatStyle.entry.message.file.thumbnail.width

          sourceComponent: $chatEntry.thumbnail ? thumbnail : extension
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
                ? ChatStyle.entry.message.outgoing.text.fontSize
                : ChatStyle.entry.message.incoming.text.fontSize
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
              color: Colors.f
              radius: ChatStyle.entry.message.file.status.bar.radius
            }

            contentItem: Item {
              Rectangle {
                color: Colors.z
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

      MouseArea {
        FileDialog {
          id: fileDialog

          folder: shortcuts.home
          title: qsTr('downloadFileTitle')
          selectExisting: false

          onAccepted: proxyModel.downloadFile(index, fileUrl)
        }

        anchors.fill: parent
        cursorShape: containsMouse
          ? Qt.PointingHandCursor
          : Qt.ArrowCursor
        hoverEnabled: true

        onClicked: fileDialog.open()
        visible: !rectangle.isNotDelivered && !$chatEntry.isOutgoing
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
          icon: rectangle.isNotDelivered ? 'chat_error' : 'chat_send'
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
