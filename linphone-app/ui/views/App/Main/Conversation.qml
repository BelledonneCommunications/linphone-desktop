import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

import 'Conversation.js' as Logic

// =============================================================================

ColumnLayout  {
  id: conversation

  property string peerAddress
  property string localAddress
  property string fullPeerAddress
  property string fullLocalAddress

  readonly property var _sipAddressObserver: SipAddressesModel.getSipAddressObserver((fullPeerAddress?fullPeerAddress:peerAddress), (fullLocalAddress?fullLocalAddress:localAddress))

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

        sipAddress: conversation.peerAddress
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
            visible: SettingsModel.videoSupported && SettingsModel.outgoingCallsEnabled && SettingsModel.showStartVideoCallButton

            onClicked: CallsListModel.launchVideoCall(conversation.peerAddress)
          }

          ActionButton {
            icon: 'call'
            visible: SettingsModel.outgoingCallsEnabled

            onClicked: CallsListModel.launchAudioCall(conversation.peerAddress)
          }
        }

        ActionBar {
          anchors.verticalCenter: parent.verticalCenter

          ActionButton {
            icon: Logic.getEditIcon()
            iconSize: ConversationStyle.bar.actions.edit.iconSize
            visible: SettingsModel.contactsEnabled

            onClicked: window.setView('ContactEdit', {
              sipAddress: conversation.peerAddress
            })
            TooltipArea {
              text: Logic.getEditTooltipText()
            }
          }

          ActionButton {
            icon: 'delete'
            iconSize: ConversationStyle.bar.actions.edit.iconSize

            onClicked: Logic.removeAllEntries()

	    TooltipArea {
	      text: qsTr('cleanHistory')
            }
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
    Layout.preferredHeight: active ? ConversationStyle.filters.height : 0

    borderColor: ConversationStyle.filters.border.color
    bottomWidth: ConversationStyle.filters.border.bottomWidth
    color: ConversationStyle.filters.backgroundColor
    topWidth: ConversationStyle.filters.border.topWidth
    visible: SettingsModel.chatEnabled

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

      Component.onCompleted: {
        if (!SettingsModel.chatEnabled) {
          setEntryTypeFilter(ChatModel.CallEntry)
        }
        resetMessageCount()
      }

      peerAddress: conversation.peerAddress
      localAddress: conversation.localAddress
      fullPeerAddress: conversation.fullPeerAddress
      fullLocalAddress: conversation.fullLocalAddress
    }
  }

  Connections {
    target: SettingsModel
    onChatEnabledChanged: chatProxyModel.setEntryTypeFilter(status ? ChatModel.GenericEntry : ChatModel.CallEntry)
  }

  Connections {
    target: AccountSettingsModel
    onAccountSettingsUpdated: {
      if (conversation.localAddress !== AccountSettingsModel.sipAddress) {
        window.setView('Home')
      }
    }
  }
}
