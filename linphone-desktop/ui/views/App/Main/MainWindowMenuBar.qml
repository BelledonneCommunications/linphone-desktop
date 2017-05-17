import QtQuick 2.7

// Experimental.
import Qt.labs.platform 1.0

import Linphone 1.0

// =============================================================================

Item {
  function open () {
    menu.open()
  }

  // ---------------------------------------------------------------------------
  // Shortcuts.
  // ---------------------------------------------------------------------------

  Shortcut {
    id: settingsShortcut

    context: Qt.ApplicationShortcut
    sequence: StandardKey.Preferences

    onActivated: App.smartShowWindow(App.getSettingsWindow())
  }

  Shortcut {
    id: quitShortcut

    context: Qt.ApplicationShortcut
    sequence: StandardKey.Quit

    onActivated: Qt.quit()
  }

  Shortcut {
    id: aboutShortcut

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
        shortcut: settingsShortcut.sequence
        text: qsTr('settings')

        onTriggered: settingsShortcut.onActivated()
      }

      MenuSeparator {}

      MenuItem {
        shortcut: quitShortcut.sequence
        text: qsTr('quit')

        onTriggered: quitShortcut.onActivated()
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
        shortcut: aboutShortcut.sequence
        text: qsTr('about')

        onTriggered: aboutShortcut.onActivated()
      }

      MenuSeparator {}

      MenuItem {
        text: qsTr('checkForUpdates')

        onTriggered: console.log('TODO')
      }
    }
  }
}
