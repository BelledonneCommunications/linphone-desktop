import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import Common 1.0 as Common

import App.Styles 1.0

 // ============================================================================

 MenuBar {
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
           text: styleData.text
         }

         shortcut: Label {
           color: styleData.selected
             ? MainWindowMenuBarStyle.subMenu.text.color.selected
             : MainWindowMenuBarStyle.subMenu.text.color.normal
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
     }

     MenuSeparator {}

     MenuItem {
       shortcut: StandardKey.Quit
       text: qsTr('quit')
     }
   }

   Menu {
     title: qsTr('tools')

     MenuItem {
       text: qsTr('accountAssistant')
     }

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

     MenuSeparator {}

     MenuItem {
       shortcut: 'Ctrl+D'
       text: qsTr('debugWindow')
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
