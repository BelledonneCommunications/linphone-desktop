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
    maximumLeftLimit: 250
    minimumLeftLimit: 110

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
      defaultClosed: true
      minimumLeftLimit: 380
      minimumRightLimit: 300
      resizeAInPriority: true

      // Call.
      childA: Incall {
        anchors.fill: parent
        sipAddress: 'sip:erwan.croze@sip.linphone.org'
      }

      // Chat.
      childB: Chat {
        anchors.fill: parent
        proxyModel: ChatProxyModel {
          id: chatProxyModel

          sipAddress: 'sip:erwan.croze@sip.linphone.org'
        }
      }
    }
  }
}
