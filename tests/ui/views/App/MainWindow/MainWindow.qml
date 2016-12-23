import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

ApplicationWindow {
  id: window

  property string _currentView: ''
  property var _lockedInfo

  // ---------------------------------------------------------------------------

  function lockView (info) {
    _lockedInfo = info
  }

  function unlockView () {
    _lockedInfo = undefined
  }

  function setView (view, props) {
    if (!_lockedInfo) {
      _setView(view, props)
      return
    }

    Utils.openConfirmDialog(window, {
      descriptionText: _lockedInfo.descriptionText,
      exitHandler: function (status) {
        if (status) {
          unlockView()
          _setView(view, props)
        } else {
          _updateSelectedEntry(_currentView, props)
        }
      },
      title: _lockedInfo.title
    })
  }

  function ensureCollapsed () {
    collapse.setCollapsed(true)
  }

  // ---------------------------------------------------------------------------

  function _updateSelectedEntry (view, props) {
    if (view === 'Home' || view === 'Contacts') {
      menu.setSelectedEntry(view === 'Home' ? 0 : 1)
      timeline.resetSelectedEntry()
    } else if (view === 'Conversation') {
      menu.resetSelectedEntry()
      timeline.setSelectedEntry(props.sipAddress)
    } else if (view === 'ContactEdit') {
      menu.resetSelectedEntry()
      timeline.resetSelectedEntry()
    }
  }

  function _setView (view, props) {
    _updateSelectedEntry(view, props)
    _currentView = view
    contentLoader.setSource(view + '.qml', props || {})
  }

  // ---------------------------------------------------------------------------
  // Window properties.
  // ---------------------------------------------------------------------------

  maximumHeight: MainWindowStyle.toolBar.height
  minimumHeight: MainWindowStyle.toolBar.height
  minimumWidth: MainWindowStyle.minimumWidth
  title: MainWindowStyle.title
  visible: true

  onActiveFocusItemChanged: activeFocusItem == null && smartSearchBar.hideMenu()

  // ---------------------------------------------------------------------------
  // Toolbar properties.
  // ---------------------------------------------------------------------------

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
        id: collapse

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

      SmartSearchBar {
        id: smartSearchBar

        Layout.fillWidth: true
        entryHeight: MainWindowStyle.searchBox.entryHeight
        maxMenuHeight: MainWindowStyle.searchBox.maxHeight
        placeholderText: qsTr('mainSearchBarPlaceholder')

        model: SmartSearchBarModel {}
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Content.
  // ---------------------------------------------------------------------------

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

      Layout.fillHeight: true
      Layout.fillWidth: true

      Component.onCompleted: setView('Home')
    }
  }
}
