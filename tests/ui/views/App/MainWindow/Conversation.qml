import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// ===================================================================

ColumnLayout  {
  property var contact

  spacing: 0

  // -----------------------------------------------------------------
  // Contact bar.
  // -----------------------------------------------------------------

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
        Layout.preferredHeight: ConversationStyle.bar.avatarSize
        Layout.preferredWidth: ConversationStyle.bar.avatarSize
        presenceLevel: contact.presenceLevel
        username: contact.username
      }

      ContactDescription {
        Layout.fillHeight: true
        Layout.fillWidth: true
        sipAddress: contact.sipAddress
        sipAddressColor: ConversationStyle.bar.description.sipAddressColor
        username: contact.username
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
            onClicked: CallsWindow.show()
          }

          ActionButton {
            icon: 'call'
            onClicked: CallsWindow.show()
          }
        }

        ActionBar {
          anchors.verticalCenter: parent.verticalCenter

          ActionButton {
            icon: 'contact_edit'
            iconSize: ConversationStyle.bar.actions.edit.iconSize

            onClicked: console.log('clicked!!!') // TODO.
          }

          ActionButton {
            icon: 'delete'
            iconSize: ConversationStyle.bar.actions.edit.iconSize

            onClicked: window.setView('Contact') // TODO.
          }
        }
      }
    }
  }

  // -----------------------------------------------------------------
  // Messages/Calls filters.
  // -----------------------------------------------------------------

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
    }
  }

  // -----------------------------------------------------------------
  // Chat.
  // -----------------------------------------------------------------

  Chat {
    Layout.fillHeight: true
    Layout.fillWidth: true
    contact: parent.contact
  }
}
