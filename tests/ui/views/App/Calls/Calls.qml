import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// ===================================================================

Window {
  id: window

  minimumHeight: 480
  minimumWidth: 960

  Paned {
    anchors.fill: parent
    defaultChildAWidth: 250
    maximumLeftLimit: 300
    minimumLeftLimit: 150

    // ---------------------------------------------------------------
    // Calls list.
    // ---------------------------------------------------------------

    childA: Rectangle {
      anchors.fill: parent
      color: 'yellow'
    }

    /* childA: ColumnLayout { */
    /*   anchors.fill: parent */
    /*   spacing: 0 */

    /*   Rectangle { */
    /*     Layout.fillWidth: true */
    /*     Layout.preferredHeight: 50 */
    /*     color: '#FFFFFF' */

    /*     ActionBar { */
    /*       anchors.verticalCenter: parent.verticalCenter */
    /*       anchors.leftMargin: 10 */
    /*       anchors.left: parent.left */
    /*       iconSize: 30 */
    /*       spacing: 16 */

    /*       ActionButton { */
    /*         icon: 'call' */
    /*       } */

    /*       ActionButton { */
    /*         icon: 'conference' */
    /*       } */
    /*     } */
    /*   } */

    /*   ScrollableListView { */
    /*     Layout.fillWidth: true */
    /*     Layout.fillHeight: true */
    /*     spacing: 1 */
    /*     delegate: CallControls { */
    /*       width: parent.width */
    /*     } */

    /*     model: callsList */
    /*   } */
    /* } */

    // ---------------------------------------------------------------
    // Content.
    // ---------------------------------------------------------------

    childB: Paned {
      anchors.fill: parent
      closingEdge: Qt.RightEdge
      defaultChildAWidth: 300
      defaultClosed: true
      minimumLeftLimit: 350
      minimumRightLimit: 250
      resizeAInPriority: true

      // Call.
      childA: OutgoingCall {
        anchors.fill: parent
        sipAddress: 'sip:erwan.croze@sip.linphone.org'
      }

      childB: Rectangle {
        anchors.fill: parent
        color: 'green'
      }

      // Chat.
      //childB: Chat {
      //  anchors.fill: parent
      //}
    }
  }

  // -----------------------------------------------------------------
  // TMP
  // -----------------------------------------------------------------

  ListModel {
    id: callsList

    ListElement {
      $presence: 'do_not_disturb'
      $sipAddress: 'charles.henri.sip.linphone.org'
    }
    ListElement {
      $presence: 'disconnected'
      $sipAddress: 'yesyes.nono.sip.linphone.org'
    }
    ListElement {
      $presence: 'connected'
      $sipAddress: 'nsa.sip.linphone.org'
    }
    ListElement {
      $presence: 'do_not_disturb'
      $sipAddress: 'charles.henri.sip.linphone.org'
    }
    ListElement {
      $presence: 'disconnected'
      $sipAddress: 'yesyes.nono.sip.linphone.org'
    }
    ListElement {
      $presence: 'connected'
      $sipAddress: 'nsa.sip.linphone.org'
    }
    ListElement {
      $presence: 'do_not_disturb'
      $sipAddress: 'charles.henri.sip.linphone.org'
    }
    ListElement {
      $presence: 'disconnected'
      $sipAddress: 'yesyes.nono.sip.linphone.org'
    }
    ListElement {
      $presence: 'connected'
      $sipAddress: 'nsa.sip.linphone.org'
    }
    ListElement {
      $presence: 'do_not_disturb'
      $sipAddress: 'charles.henri.sip.linphone.org'
    }
    ListElement {
      $presence: 'disconnected'
      $sipAddress: 'yesyes.nono.sip.linphone.org'
    }
    ListElement {
      $presence: 'connected'
      $sipAddress: 'nsa.sip.linphone.org'
    }
    ListElement {
      $presence: 'do_not_disturb'
      $sipAddress: 'charles.henri.sip.linphone.org'
    }
    ListElement {
      $presence: 'disconnected'
      $sipAddress: 'yesyes.nono.sip.linphone.org'
    }
    ListElement {
      $presence: 'connected'
      $sipAddress: 'nsa.sip.linphone.org'
    }
    ListElement {
      $presence: 'do_not_disturb'
      $sipAddress: 'charles.henri.sip.linphone.org'
    }
    ListElement {
      $presence: 'disconnected'
      $sipAddress: 'yesyes.nono.sip.linphone.org'
    }
    ListElement {
      $presence: 'connected'
      $sipAddress: 'nsa.sip.linphone.org'
    }
    ListElement {
      $presence: 'do_not_disturb'
      $sipAddress: 'charles.henri.sip.linphone.org'
    }
    ListElement {
      $presence: 'disconnected'
      $sipAddress: 'yesyes.nono.sip.linphone.org'
    }
    ListElement {
      $presence: 'connected'
      $sipAddress: 'nsa.sip.linphone.org'
    }
  }
}
