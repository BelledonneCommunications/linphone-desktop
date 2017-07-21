import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

import 'MainWindow.js' as Logic

// =============================================================================

ApplicationWindow {
  id: window

  property string _currentView
  property var _lockedInfo

  // ---------------------------------------------------------------------------

  function lockView (info) {
    Logic.lockView(info)
  }

  function unlockView () {
    Logic.unlockView()
  }

  function setView (view, props) {
    Logic.setView(view, props)
  }

  // ---------------------------------------------------------------------------
  // Window properties.
  // ---------------------------------------------------------------------------

  minimumHeight: MainWindowStyle.minimumHeight
  minimumWidth: MainWindowStyle.minimumWidth

  title: MainWindowStyle.title

  // ---------------------------------------------------------------------------

  onActiveFocusItemChanged: Logic.handleActiveFocusItemChanged(activeFocusItem)
  onClosing: Logic.handleClosing(close)

  // ---------------------------------------------------------------------------

  Connections {
    target: CoreManager
    onCoreStarted: mainLoader.active = true
  }

  Shortcut {
    sequence: StandardKey.Close
    onActivated: window.hide()
  }

  // ---------------------------------------------------------------------------

  Loader {
    id: mainLoader

    active: false
    anchors.fill: parent

    sourceComponent: ColumnLayout {
      // Workaround to get these properties in `MainWindow.js`.
      readonly property alias contentLoader: contentLoader
      readonly property alias menu: menu
      readonly property alias timeline: timeline

      spacing: 0

      // -----------------------------------------------------------------------

      AuthenticationNotifier {
        onAuthenticationRequested: Logic.handleAuthenticationRequested(authInfo, realm, sipAddress, userId)
      }

      // -----------------------------------------------------------------------
      // Toolbar properties.
      // -----------------------------------------------------------------------

      ToolBar {
        Layout.fillWidth: true
        Layout.preferredHeight: MainWindowStyle.toolBar.height

        background: MainWindowStyle.toolBar.background

        RowLayout {
          anchors {
            fill: parent
            leftMargin: MainWindowStyle.toolBar.leftMargin
            rightMargin: MainWindowStyle.toolBar.rightMargin
          }
          spacing: MainWindowStyle.toolBar.spacing

          AccountStatus {
            id: accountStatus

            Layout.fillHeight: parent.height
            Layout.preferredWidth: MainWindowStyle.accountStatus.width

            TooltipArea {
              text: AccountSettingsModel.sipAddress
            }

            onClicked: Logic.manageAccounts()
          }

          Column {
            Layout.preferredWidth: MainWindowStyle.autoAnswerStatus.width

            Icon {
              icon: SettingsModel.autoAnswerStatus
                ? 'auto_answer'
                : ''
              iconSize: MainWindowStyle.autoAnswerStatus.iconSize
            }

            Text {
              clip: true
              color: MainWindowStyle.autoAnswerStatus.text.color
              font.pointSize: MainWindowStyle.autoAnswerStatus.text.pointSize
              text: qsTr('autoAnswerStatus')
              visible: SettingsModel.autoAnswerStatus
              width: parent.width
            }
          }

          SmartSearchBar {
            id: smartSearchBar

            Layout.fillWidth: true

            maxMenuHeight: MainWindowStyle.searchBox.maxHeight
            placeholderText: qsTr('mainSearchBarPlaceholder')

            onAddContact: window.setView('ContactEdit', {
              sipAddress: sipAddress
            })

            onEntryClicked: window.setView(entry.contact ? 'ContactEdit' : 'Conversation', {
              sipAddress: entry.sipAddress
            })

            onLaunchCall: CallsListModel.launchAudioCall(sipAddress)
            onLaunchChat: window.setView('Conversation', {
              sipAddress: sipAddress
            })

            onLaunchVideoCall: CallsListModel.launchVideoCall(sipAddress)

            TooltipArea {
              text: qsTr('smartSearchBarTooltip')
              visible: !smartSearchBar.isOpen
            }
          }

          ActionButton {
            icon: 'new_conference'
            iconSize: MainWindowStyle.newConferenceSize

            onClicked: Logic.openConferenceManager()
          }

          ActionButton {
            icon: 'burger_menu'
            iconSize: MainWindowStyle.menuBurgerSize
            visible: Qt.platform.os !== 'osx'

            onClicked: menuBar.open()

            MainWindowMenuBar {
              id: menuBar
            }
          }
        }
      }

      // -----------------------------------------------------------------------
      // Content.
      // -----------------------------------------------------------------------

      RowLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true

        spacing: 0

        // Main menu.
        ColumnLayout {
          Layout.maximumWidth: MainWindowStyle.menu.width
          Layout.preferredWidth: MainWindowStyle.menu.width

          spacing: 0

          ApplicationMenu {
            id: menu

            entryHeight: MainWindowStyle.menu.height
            entryWidth: MainWindowStyle.menu.width

            entries: [{
              entryName: qsTr('homeEntry'),
              icon: 'home'
            }, {
              entryName: qsTr('contactsEntry'),
              icon: 'contact'
            }]

            onEntrySelected: !entry ? setView('Home') : setView('Contacts')
          }

          // History.
          Timeline {
            id: timeline

            Layout.fillHeight: true
            Layout.fillWidth: true
            model: TimelineModel

            onEntrySelected: setView('Conversation', { sipAddress: entry })
          }
        }

        // Main content.
        Loader {
          id: contentLoader

          objectName: '__contentLoader'

          Layout.fillHeight: true
          Layout.fillWidth: true

          source: 'Home.qml'
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Hiden button to force registration.
  // ---------------------------------------------------------------------------

  Button {
    anchors {
      top: parent.top
      left: parent.left
    }

    background: Rectangle {
      color: 'transparent' // Not a style.
    }

    flat: true

    height: MainWindowStyle.toolBar.height
    width: MainWindowStyle.toolBar.leftMargin

    onClicked: CoreManager.forceRefreshRegisters()
  }

  // ---------------------------------------------------------------------------
  // Url handlers.
  // ---------------------------------------------------------------------------

  Connections {
    target: UrlHandlers

    onSip: window.setView('Conversation', {
      sipAddress: sipAddress
    })
  }
}
