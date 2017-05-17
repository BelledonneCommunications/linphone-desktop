import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

import 'ConferenceManager.js' as Logic

// =============================================================================

ConfirmDialog {
  descriptionText: qsTr('conferenceManagerDescription')

  height: ConferenceManagerStyle.height
  width: ConferenceManagerStyle.width

  // ---------------------------------------------------------------------------

  RowLayout {
    anchors {
      fill: parent
      leftMargin: ConferenceManagerStyle.leftMargin
      rightMargin: ConferenceManagerStyle.rightMargin
    }

    spacing: 0

    // -------------------------------------------------------------------------
    // Address selector.
    // -------------------------------------------------------------------------

    Item {
      Layout.fillHeight: true
      Layout.fillWidth: true

      ColumnLayout {
        anchors.fill: parent
        spacing: ConferenceManagerStyle.columns.selector.spacing

        TextField {
          id: filter

          Layout.fillWidth: true

          icon: 'search'

          onTextChanged: Logic.updateFilter(text)
        }

        ScrollableListViewField {
          Layout.fillHeight: true
          Layout.fillWidth: true

          SipAddressesView {
            id: view

            anchors.fill: parent

            actions: [{
              icon: 'video_call',
              handler: function (entry) {
                console.log('toto')
              }
            }]

            genSipAddress: filter.text

            onEntryClicked: {
              console.log('todo2')
            }
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Separator.
    // -------------------------------------------------------------------------

    Rectangle {
      Layout.fillHeight: true
      Layout.leftMargin: ConferenceManagerStyle.leftMargin
      Layout.preferredWidth: ConferenceManagerStyle.columns.separator.width
      Layout.rightMargin: ConferenceManagerStyle.rightMargin

      color: ConferenceManagerStyle.columns.separator.color
    }

    // -------------------------------------------------------------------------
    // See and remove selected addresses.
    // -------------------------------------------------------------------------

    ScrollableListViewField {
      Layout.topMargin: filter.height + ConferenceManagerStyle.columns.selector.spacing
      Layout.fillHeight: true
      Layout.fillWidth: true
    }
  }
}
