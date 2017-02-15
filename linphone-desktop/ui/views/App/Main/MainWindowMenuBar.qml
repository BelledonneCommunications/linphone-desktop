import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

 // ============================================================================

 MenuBar {
   style: MenuBarStyle {
     background: Rectangle {
       anchors.fill: parent
       color: '#E8E8E7'
     }

     itemDelegate: Rectangle {
       implicitHeight: text.height + 8
       implicitWidth: text.width + 18
       color: 'transparent'

       Text {
         id: text

         anchors.centerIn: parent
         font: root.font
         text: formatMnemonic(styleData.text, styleData.underlineMnemonic)
         color: styleData.open ? '#FE5E00' : '#515557'
       }
     }
   }

   // --------------------------------------------------------------------------

   Menu {
     title: qsTr('options')

     MenuItem {
       text: qsTr('settings')
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
       text: qsTr('debugWindow')
     }
   }

   Menu {
     title: qsTr('help')

     MenuItem {
       text: qsTr('about')
     }
   }

 }
