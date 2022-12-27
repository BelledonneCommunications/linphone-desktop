import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml 2.12

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
  id: conferenceManager

  readonly property int maxParticipants: 20
  readonly property int minParticipants: 1
  
  property ChatRoomModel chatRoomModel	// Used to initialize participants
  property bool autoCall : false

  buttons: [
    TextButtonA {
      text: qsTr('cancel')

      onClicked: exit(0)
    },
    TextButtonB {
      enabled: toAddView.count >= conferenceManager.minParticipants
      text: qsTr('confirm')

      onClicked: {
        conferenceHelperModel.toAdd.update()
        exit(1)
      }
    }
  ]
  
  buttonsAlignment: Qt.AlignCenter
  descriptionText: qsTr('conferenceManagerDescription')

  height: ConferenceManagerStyle.height + 30
  width: ConferenceManagerStyle.width
  
  Timer{
	id:delayedExit
	onTriggered : exit(1)
	interval:1
  }

	Component.onCompleted: if(chatRoomModel){
		conferenceHelperModel.toAdd.addParticipants(chatRoomModel)
		if(autoCall) {
			conferenceHelperModel.toAdd.update()
			visible = false
			delayedExit.start()
		}
	}
  // ---------------------------------------------------------------------------

  RowLayout {
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
        spacing: ConferenceManagerStyle.columns.selector.spacing

        TextField {
          id: filter

          Layout.fillWidth: true

          icon: text == '' ? 'search_custom' : 'close_custom'
          overwriteColor: ConferenceManagerStyle.searchField.colorModel.color

          onTextChanged: conferenceHelperModel.setFilter(text)
        }

        ScrollableListViewField {
          Layout.fillHeight: true
          Layout.fillWidth: true

          readOnly: toAddView.count >= conferenceManager.maxParticipants

          SipAddressesView {
            anchors.fill: parent

			function transfer(sipAddress){
				conferenceHelperModel.toAdd.addToConference(sipAddress)
			}
            actions: [{
              colorSet: ConferenceManagerStyle.transfer,
              secure:0,
              visible: true,
              handler: function (entry) {
				transfer(entry.sipAddress)  
              },
              handerSipAddress: function(sipAddress){
				transfer(sipAddress)
              }
              
            }]

            genSipAddress: filter.text

            model: ConferenceHelperModel {
              id: conferenceHelperModel
            }

            onEntryClicked: actions[0].handerSipAddress(entry.sipAddress)
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Separator.
    // -------------------------------------------------------------------------

    Rectangle {
      Layout.fillHeight: true
      Layout.leftMargin: ConferenceManagerStyle.columns.separator.leftMargin
      Layout.preferredWidth: ConferenceManagerStyle.columns.separator.width
      Layout.rightMargin: ConferenceManagerStyle.columns.separator.rightMargin

      color: ConferenceManagerStyle.columns.separator.colorModel.color
    }

    // -------------------------------------------------------------------------
    // See and remove selected addresses.
    // -------------------------------------------------------------------------

    ScrollableListViewField {
      Layout.fillHeight: true
      Layout.fillWidth: true
      Layout.topMargin: filter.height + ConferenceManagerStyle.columns.selector.spacing

      SipAddressesView {
        id: toAddView

        anchors.fill: parent

		function cancel(sipAddress){
			model.removeFromConference(sipAddress)
		}
        actions: [{
          colorSet: ConferenceManagerStyle.cancel,
          visible:true,
          secure:0,
          handler: function (entry) {
			  cancel(entry.sipAddress)
          },
          handlerSipAddress: function(sipAddress){
			cancel(sipAddress)
          }
        }]

        model: conferenceHelperModel.toAdd

        onEntryClicked: actions[0].handlerSipAddress(entry)
      }
    }
  }
}
