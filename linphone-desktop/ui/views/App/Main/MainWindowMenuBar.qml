import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2

import Linphone 1.0

import App.Styles 1.0

// ============================================================================

MenuBar {
  id: container

  // --------------------------------------------------------------------------

  property bool hide: false

  // --------------------------------------------------------------------------

  // Workaround to hide toolbar.
  // Use private properties of MenuBar.

  __contentItem.height: hide
    ? 0
    : MainWindowMenuBarStyle.height

  __contentItem.transform: Scale {
    yScale: Number(!hide)
  }

  // --------------------------------------------------------------------------

  style: MenuBarStyle {
    background: Rectangle {
      color: MainWindowMenuBarStyle.color

      Rectangle {
        anchors.bottom: parent.bottom
        color: MainWindowMenuBarStyle.separator.color
        height: MainWindowMenuBarStyle.separator.height
        width: parent.width
      }
    }

    menuStyle: MenuStyle {
      id: menuStyle

      font.pointSize: MainWindowMenuBarStyle.subMenu.text.fontSize

      frame: Item {}

      itemDelegate {
        background: Rectangle {
          color: (styleData.selected || styleData.open)
            ? MainWindowMenuBarStyle.subMenu.color.selected
            : MainWindowMenuBarStyle.subMenu.color.normal
        }

        label: Label {
          color: styleData.selected
            ? MainWindowMenuBarStyle.subMenu.text.color.selected
            : MainWindowMenuBarStyle.subMenu.text.color.normal
          font: menuStyle.font
          text: styleData.text
        }

        shortcut: Label {
          color: styleData.selected
            ? MainWindowMenuBarStyle.subMenu.text.color.selected
            : MainWindowMenuBarStyle.subMenu.text.color.normal
          font: menuStyle.font
          text: styleData.shortcut
        }
      }
    }

    itemDelegate: Item {
      implicitHeight: menuItem.height + MainWindowMenuBarStyle.separator.spacing
      implicitWidth: menuItem.width

      Item {
        id: menuItem

        implicitHeight: text.height + MainWindowMenuBarStyle.menu.text.verticalMargins * 2
        implicitWidth: text.width + MainWindowMenuBarStyle.menu.text.horizontalMargins * 2

        Text {
          id: text

          anchors.centerIn: parent
          color: styleData.open
            ? MainWindowMenuBarStyle.menu.text.color.selected
            : MainWindowMenuBarStyle.menu.text.color.normal

          font.pointSize: MainWindowMenuBarStyle.menu.text.fontSize
          text: formatMnemonic(styleData.text, styleData.underlineMnemonic)
        }

        Rectangle {
          anchors.bottom: parent.bottom
          color: MainWindowMenuBarStyle.menu.indicator.color
          visible: styleData.open

          height: MainWindowMenuBarStyle.menu.indicator.height
          width: parent.width
        }
      }
    }
  }

  // --------------------------------------------------------------------------

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

  Menu {
    title: qsTr('tools')

    MenuItem {
      text: qsTr('audioAssistant')
    }

    MenuSeparator {}

    MenuItem {
      text: qsTr('importContacts')
    }

    MenuItem {
      text: qsTr('exportContacts')
    }
  }

  Menu {
    title: qsTr('help')

    MenuItem {
      shortcut: StandardKey.HelpContents
      text: qsTr('about')
    }

    MenuSeparator {}

    MenuItem {
      text: qsTr('checkForUpdates')
    }
  }
}
