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

  function setView (view, props) {
    contentLoader.setSource(view + '.qml', props || {})
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
      anchors {
        fill: parent
        leftMargin: MainWindowStyle.toolBar.leftMargin
        rightMargin: MainWindowStyle.toolBar.rightMargin
      }
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
            ? 'auto_answer'
            : ''
          iconSize: MainWindowStyle.autoAnswerStatus.iconSize
        }

        Text {
          clip: true
          font {
            pointSize: MainWindowStyle.autoAnswerStatus.text.fontSize
          }
          text: qsTr('autoAnswerStatus')
          width: parent.width
          color: MainWindowStyle.autoAnswerStatus.text.color
        }
      }

      SearchBox {
        id: searchBox

        Layout.fillWidth: true
        entryHeight: MainWindowStyle.searchBox.entryHeight
        maxMenuHeight: MainWindowStyle.searchBox.maxHeight
        placeholderText: qsTr('mainSearchBarPlaceholder')

        model: ContactsListProxyModel {}

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
        id: menu

        entryHeight: MainWindowStyle.menu.entryHeight
        entryWidth: MainWindowStyle.menu.width

        entries: [{
          entryName: qsTr('homeEntry'),
          icon: 'home'
        }, {
          entryName: qsTr('contactsEntry'),
          icon: 'contact'
        }]

        onEntrySelected: {
          timeline.resetSelectedItem()

          if (entry === 0) {
            setView('Home')
          } else if (entry === 1) {
            setView('Contacts')
          }
        }
      }

      // History.
      Timeline {
        id: timeline

        Layout.fillHeight: true
        Layout.fillWidth: true
        model: TimelineModel

        onContactSelected: {
          menu.resetSelectedEntry()
          setView('Conversation', { contact: contact })
        }
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
