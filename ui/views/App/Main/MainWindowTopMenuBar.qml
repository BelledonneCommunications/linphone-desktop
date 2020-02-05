import QtQuick 2.7
import QtQuick.Controls 2.3
import Qt.labs.platform 1.0

import Linphone 1.0

// =============================================================================

MenuBar {
  function open () {
    menu.open()
  }

  // ---------------------------------------------------------------------------
  // Shortcuts.
  // ---------------------------------------------------------------------------

  Shortcut {
    id: settingsShortcut

    sequence: 'Ctrl+P'

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
      window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/About.qml'))
    }
  }

  // ---------------------------------------------------------------------------
  // Menu.
  // ---------------------------------------------------------------------------

  Menu {
    id: menu
    title: qsTr('settings')

    MenuItem {
      text: qsTr('settings')

      onTriggered: settingsShortcut.onActivated()
    }

    MenuItem {
      text: qsTr('about')

      onTriggered: aboutShortcut.onActivated()
    }

    MenuItem {
      text: qsTr('quit')

      onTriggered: quitShortcut.onActivated()
    }
  }
}
