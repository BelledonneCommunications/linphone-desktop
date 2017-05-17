import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2
import Qt.labs.platform 1.0

import Linphone 1.0

import App.Styles 1.0

// =============================================================================

Item {
  function open() {
    menu.open()
  }

  // ---------------------------------------------------------------------------
  // Shortcuts.
  // ---------------------------------------------------------------------------
  
  Shortcut {
    id: settings_shortcut
    sequence: StandardKey.Preferences
    onActivated: {
      var window = App.getSettingsWindow()
      if (window.visibility === Window.Minimized) {
        window.visibility = Window.AutomaticVisibility
      } else {
        window.setVisible(true)
      }
    }
  }

  Shortcut {
    id: quit_shortcut
    sequence: StandardKey.Quit
    context: Qt.ApplicationShortcut
    onActivated: Qt.quit()
  }
  
  Shortcut {
    id: about_shortcut
    sequence: StandardKey.HelpContents
    onActivated: {
      window.detachVirtualWindow()
      window.attachVirtualWindow(Qt.resolvedUrl('About.qml'))
    }
  }

  // ---------------------------------------------------------------------------
  // Menu.
  // ---------------------------------------------------------------------------

  Menu {
    id: menu

    Menu {
      title: qsTr('options')

      MenuItem {
        shortcut: settings_shortcut.sequence
        text: qsTr('settings')

        onTriggered: settings_shortcut.onActivated()
      }

      MenuSeparator {}

      MenuItem {
        shortcut: quit_shortcut.sequence
        text: qsTr('quit')

        onTriggered: quit_shortcut.onActivated()
      }
    }

    // ---------------------------------------------------------------------------
    // Tools.
    // ---------------------------------------------------------------------------

    Menu {
      title: qsTr('tools')

      MenuItem {
        text: qsTr('audioAssistant')

        onTriggered: console.log('TODO')
      }
    }

    // ---------------------------------------------------------------------------
    // Help.
    // ---------------------------------------------------------------------------

    Menu {
      title: qsTr('help')

      MenuItem {
        shortcut: about_shortcut.sequence
        text: qsTr('about')

        onTriggered: about_shortcut.onActivated()
      }

      MenuSeparator {}

      MenuItem {
        text: qsTr('checkForUpdates')

        onTriggered: console.log('TODO')
      }
    }
  }
}