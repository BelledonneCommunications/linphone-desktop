import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
  buttons: [
    TextButtonA {
      text: qsTr('cancel')

      onClicked: exit(0)
    }
  ]

  centeredButtons: true
  descriptionText: qsTr('callSipAddressDescription')

  height: CallSipAddressStyle.height
  width: CallSipAddressStyle.width

  // ---------------------------------------------------------------------------

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    // -------------------------------------------------------------------------
    // Address selector.
    // -------------------------------------------------------------------------

    Item {
      Layout.fillHeight: true
      Layout.fillWidth: true

      ColumnLayout {
        anchors.fill: parent
        spacing: CallSipAddressStyle.spacing

        TextField {
          id: filter

          Layout.fillWidth: true

          icon: 'search'

          onTextChanged: sipAddressesModel.setFilter(text)
        }

        ScrollableListViewField {
          Layout.fillHeight: true
          Layout.fillWidth: true

          SipAddressesView {
            anchors.fill: parent

            actions: [{
              icon: 'video_call',
              handler: function (entry) {
                CallsListModel.launchVideoCall(entry.sipAddress)
                exit(1)
              }
            }, {
              icon: 'call',
              handler: function (entry) {
                CallsListModel.launchAudioCall(entry.sipAddress)
                exit(1)
              }
            }]

            genSipAddress: filter.text

            model: SipAddressesProxyModel {
              id: sipAddressesModel
            }

            onEntryClicked: actions[0].handler(entry)
          }
        }
      }
    }
  }
}
