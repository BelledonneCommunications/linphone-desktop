import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

import 'Conversation.js' as Logic

// =============================================================================

ColumnLayout  {
  id: conversation

  property string sipAddress

  readonly property var _sipAddressObserver: SipAddressesModel.getSipAddressObserver(sipAddress)

  // ---------------------------------------------------------------------------

  spacing: 0

  // ---------------------------------------------------------------------------
  // Contact bar.
  // ---------------------------------------------------------------------------

  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: ConversationStyle.bar.height

    color: ConversationStyle.bar.backgroundColor

    RowLayout {
      anchors {
        fill: parent
        leftMargin: ConversationStyle.bar.leftMargin
        rightMargin: ConversationStyle.bar.rightMargin
      }
      spacing: ConversationStyle.bar.spacing

      Avatar {
        id: avatar

        Layout.preferredHeight: ConversationStyle.bar.avatarSize
        Layout.preferredWidth: ConversationStyle.bar.avatarSize

        image: Logic.getAvatar()

        presenceLevel: Presence.getPresenceLevel(
          conversation._sipAddressObserver.presenceStatus
        )

        username: Logic.getUsername()
      }

      ContactDescription {
        Layout.fillHeight: true
        Layout.fillWidth: true

        sipAddress: conversation.sipAddress
        sipAddressColor: ConversationStyle.bar.description.sipAddressColor
        username: avatar.username
        usernameColor: ConversationStyle.bar.description.usernameColor
      }

      Row {
        Layout.fillHeight: true

        spacing: ConversationStyle.bar.actions.spacing

        ActionBar {
          anchors.verticalCenter: parent.verticalCenter
          iconSize: ConversationStyle.bar.actions.call.iconSize

          ActionButton {
            icon: 'video_call'
            onClicked: CallsListModel.launchVideoCall(conversation.sipAddress)
          }

          ActionButton {
            icon: 'call'
            onClicked: CallsListModel.launchAudioCall(conversation.sipAddress)
          }
        }

        ActionBar {
          anchors.verticalCenter: parent.verticalCenter

          ActionButton {
            icon: Logic.getEditIcon()
            iconSize: ConversationStyle.bar.actions.edit.iconSize

            onClicked: window.setView('ContactEdit', {
              sipAddress: conversation.sipAddress
            })
          }

          ActionButton {
            icon: 'delete'
            iconSize: ConversationStyle.bar.actions.edit.iconSize

            onClicked: Logic.removeAllEntries()
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Messages/Calls filters.
  // ---------------------------------------------------------------------------

  Borders {
    Layout.fillWidth: true
    Layout.preferredHeight: ConversationStyle.filters.height

    borderColor: ConversationStyle.filters.border.color
    bottomWidth: ConversationStyle.filters.border.bottomWidth
    color: ConversationStyle.filters.backgroundColor
    topWidth: ConversationStyle.filters.border.topWidth

    ExclusiveButtons {
      anchors {
        left: parent.left
        leftMargin: ConversationStyle.filters.leftMargin
        verticalCenter: parent.verticalCenter
      }

      texts: [
        qsTr('displayCallsAndMessages'),
        qsTr('displayCalls'),
        qsTr('displayMessages')
      ]

      onClicked: Logic.updateChatFilter(button)
    }
  }

  // ---------------------------------------------------------------------------
  // Chat.
  // ---------------------------------------------------------------------------

  Chat {
    Layout.fillHeight: true
    Layout.fillWidth: true

    proxyModel: ChatProxyModel {
      id: chatProxyModel

      sipAddress: conversation.sipAddress
    }
  }
}
