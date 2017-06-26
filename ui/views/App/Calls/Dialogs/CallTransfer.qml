import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
  id: callTransfer

  // ---------------------------------------------------------------------------

  property var call

  // ---------------------------------------------------------------------------

  buttons: [
    TextButtonA {
      text: qsTr('cancel')

      onClicked: exit(0)
    }
  ]

  centeredButtons: true
  descriptionText: qsTr('callTransferDescription')

  height: CallTransferStyle.height
  width: CallTransferStyle.width

  onCallChanged: !call && exit(0)

  // ---------------------------------------------------------------------------

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    // -------------------------------------------------------------------------
    // Contact.
    // -------------------------------------------------------------------------

    Contact {
      Layout.fillWidth: true

      entry: SipAddressesModel.getSipAddressObserver(call ? call.sipAddress : '')
    }

    // -------------------------------------------------------------------------
    // Address selector.
    // -------------------------------------------------------------------------

    Item {
      Layout.fillHeight: true
      Layout.fillWidth: true

      ColumnLayout {
        anchors.fill: parent
        spacing: CallTransferStyle.spacing

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
              icon: 'transfer',
              handler: function (entry) {
                callTransfer.call.transferTo(entry.sipAddress)
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
