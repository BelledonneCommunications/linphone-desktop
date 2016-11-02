import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// ===================================================================

ApplicationWindow {
  id: window

  function setView (view) {
    contentLoader.source = view + '.qml'
  }

  // -----------------------------------------------------------------
  // Window properties.
  // -----------------------------------------------------------------

  maximumHeight: MainWindowStyle.toolBar.height
  minimumHeight: MainWindowStyle.toolBar.height
  minimumWidth: MainWindowStyle.minimumWidth
  title: MainWindowStyle.title
  visible: true

  onActiveFocusItemChanged: activeFocusItem == null &&
    searchBox.hideMenu()

  // -----------------------------------------------------------------
  // Toolbar properties.
  // -----------------------------------------------------------------

  header: ToolBar {
    background: MainWindowStyle.toolBar.background
    height: MainWindowStyle.toolBar.height

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: MainWindowStyle.toolBar.leftMargin
      anchors.rightMargin: MainWindowStyle.toolBar.rightMargin
      spacing: MainWindowStyle.toolBar.spacing

      Collapse {
        Layout.fillHeight: parent.height
        target: window
        targetHeight: MainWindowStyle.minimumHeight
      }

      AccountStatus {
        id: accountStatus

        Layout.fillHeight: parent.height
        Layout.preferredWidth: MainWindowStyle.accountStatus.width

        onClicked: Utils.openWindow('ManageAccounts', window)
      }

      Column {
        width: MainWindowStyle.autoAnswerStatus.width

        Icon {
          icon: AccountSettingsModel.autoAnswerStatus
            ? 'auto_answer_active'
            : 'auto_answer_inactive'
          iconSize: MainWindowStyle.autoAnswerStatus.iconSize
        }

        Text {
          clip: true
          font {
            pointSize: MainWindowStyle.autoAnswerStatus.text.fontSize
          }
          text: qsTr('autoAnswerStatus')
          width: parent.width
          color: AccountSettingsModel.autoAnswerStatus
            ? MainWindowStyle.autoAnswerStatus.text.color.enabled
            : MainWindowStyle.autoAnswerStatus.text.color.disabled
        }
      }

      SearchBox {
        id: searchBox

        Layout.fillWidth: true
        entryHeight: MainWindowStyle.searchBox.entryHeight
        maxMenuHeight: MainWindowStyle.searchBox.maxHeight
        placeholderText: qsTr('mainSearchBarPlaceholder')

        model: ContactsListModel {}

        delegate: Contact {
          contact: $contact
          width: parent.width

          actions: [
            ActionButton {
              icon: 'call'
              onClicked: CallsWindow.show()
            },

            ActionButton {
              icon: 'video_call'
              onClicked: CallsWindow.show()
            }
          ]
        }
      }
    }
  }

  // -----------------------------------------------------------------
  // Content.
  // -----------------------------------------------------------------

  RowLayout {
    anchors.fill: parent
    spacing: 0

    // Main menu.
    ColumnLayout {
      Layout.fillHeight: true
      Layout.maximumWidth: MainWindowStyle.menu.width
      Layout.preferredWidth: MainWindowStyle.menu.width
      spacing: 0

      Menu {
        entryHeight: MainWindowStyle.menu.entryHeight
        entryWidth: parent.width

        entries: [{
          entryName: qsTr('homeEntry'),
          icon: 'home'
        }, {
          entryName: qsTr('contactsEntry'),
          icon: 'contact'
        }]

        onEntrySelected: {
          if (entry === 0) {
            setView('Home')
          } else if (entry === 1) {
            setView('Contacts')
          }
        }
      }

      // History.
      Timeline {
        Layout.fillHeight: true
        Layout.fillWidth: true
        model: ContactsListModel {} // Use History list.

        onClicked: setView('Conversation')
      }
    }

    // Main content.
    Loader {
      id: contentLoader

      Layout.fillHeight: true
      Layout.fillWidth: true

      Component.onCompleted: setView('Home')
    }
  }
}
