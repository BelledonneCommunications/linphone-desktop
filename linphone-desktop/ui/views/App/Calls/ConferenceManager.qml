import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

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

          onTextChanged: conferenceHelperModel.setFilter(text)
        }

        ScrollableListViewField {
          Layout.fillHeight: true
          Layout.fillWidth: true

          SipAddressesView {
            anchors.fill: parent

            actions: [{
              icon: 'video_call', // TODO: replace me.
              handler: function (entry) {
                conferenceHelperModel.toAdd.addToConference(entry.sipAddress)
              }
            }]

            genSipAddress: filter.text

            model: ConferenceHelperModel {
              id: conferenceHelperModel
            }

            onEntryClicked: actions[0].handler(entry)
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
      Layout.fillHeight: true
      Layout.fillWidth: true
      Layout.topMargin: filter.height + ConferenceManagerStyle.columns.selector.spacing

      SipAddressesView {
        anchors.fill: parent

        actions: [{
          icon: 'video_call', // TODO: replace me.
          handler: function (entry) {
            model.removeFromConference(entry.sipAddress)
          }
        }]

        model: conferenceHelperModel.toAdd
      }
    }
  }
}
