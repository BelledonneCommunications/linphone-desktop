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

  Menu {
    id: menu

    Menu {
      title: qsTr('options')

      MenuItem {
        shortcut: 'Ctrl+P'
        text: qsTr('settings')

        onTriggered: {
          var window = App.getSettingsWindow()
          if (window.visibility === Window.Minimized) {
            window.visibility = Window.AutomaticVisibility
          } else {
            window.setVisible(true)
          }
        }
      }

      MenuSeparator {}

      MenuItem {
        shortcut: StandardKey.Quit
        text: qsTr('quit')

        onTriggered: Qt.quit()
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
        shortcut: StandardKey.HelpContents
        text: qsTr('about')

        onTriggered: {
          window.detachVirtualWindow()
          window.attachVirtualWindow(Qt.resolvedUrl('About.qml'))
        }
      }

      MenuSeparator {}

      MenuItem {
        text: qsTr('checkForUpdates')

        onTriggered: console.log('TODO')
      }
    }
  }
}