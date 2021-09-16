import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import UtilsCpp 1.0

import App.Styles 1.0

import 'HistoryView.js' as Logic

// =============================================================================

ColumnLayout  {
  id: historyView

  property string peerAddress
  property string fullPeerAddress

  readonly property var _sipAddressObserver: peerAddress?SipAddressesModel.getSipAddressObserver((fullPeerAddress?fullPeerAddress:peerAddress), ''):null


  // ---------------------------------------------------------------------------

  spacing: 0

  // ---------------------------------------------------------------------------
  // Contact bar.
  // ---------------------------------------------------------------------------

  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: peerAddress?HistoryViewStyle.bar.height:HistoryViewStyle.bar.height/2

    color: HistoryViewStyle.bar.backgroundColor

    RowLayout {
      anchors {
        fill: parent
        leftMargin: HistoryViewStyle.bar.leftMargin
        rightMargin: HistoryViewStyle.bar.rightMargin
      }
      spacing: HistoryViewStyle.bar.spacing
      
        layoutDirection: peerAddress?Qt.LeftToRight :Qt.RightToLeft 

      Avatar {
        id: avatar

        Layout.preferredHeight: HistoryViewStyle.bar.avatarSize
        Layout.preferredWidth: HistoryViewStyle.bar.avatarSize

        image: peerAddress?Logic.getAvatar():null

        presenceLevel: historyView._sipAddressObserver?Presence.getPresenceLevel(
          historyView._sipAddressObserver.presenceStatus
        ):null

        username: peerAddress? UtilsCpp.getDisplayName(historyView._sipAddressObserver.peerAddress):null
        visible:peerAddress
      }

      ContactDescription {
        Layout.fillHeight: true
        Layout.fillWidth: true

        sipAddress: historyView.peerAddress
        sipAddressColor: HistoryViewStyle.bar.description.sipAddressColor
        username: avatar.username
        usernameColor: HistoryViewStyle.bar.description.usernameColor
        visible:peerAddress
      }

      Row {
        Layout.fillHeight: true

        spacing: HistoryViewStyle.bar.actions.spacing
        
        ActionBar {
          anchors.verticalCenter: parent.verticalCenter
          iconSize: HistoryViewStyle.bar.actions.call.iconSize

          ActionButton {
            isCustom: true
			backgroundRadius: 90
			colorSet: ContactsStyle.videoCall
            visible: peerAddress && SettingsModel.videoSupported && SettingsModel.outgoingCallsEnabled && SettingsModel.showStartVideoCallButton

            onClicked: CallsListModel.launchVideoCall(historyView.peerAddress)
          }

          ActionButton {
            isCustom: true
			backgroundRadius: 90
			colorSet: ContactsStyle.call
            visible: peerAddress && SettingsModel.outgoingCallsEnabled

            onClicked: CallsListModel.launchAudioCall(historyView.peerAddress)
          }
        }

        ActionBar {
          anchors.verticalCenter: parent.verticalCenter

          ActionButton {
			isCustom: true
			backgroundRadius: 4
			colorSet: historyView._sipAddressObserver && historyView._sipAddressObserver.contact ? ConversationStyle.bar.actions.edit.viewContact : ConversationStyle.bar.actions.edit.addContact
            iconSize: HistoryViewStyle.bar.actions.edit.iconSize
            visible: peerAddress && SettingsModel.contactsEnabled

            onClicked: window.setView('ContactEdit', { sipAddress: historyView.peerAddress })
            tooltipText: peerAddress?Logic.getEditTooltipText():''
          }

          ActionButton {
            isCustom: true
			backgroundRadius: 90
			colorSet: ContactsStyle.deleteAction

            onClicked: Logic.removeAllEntries()

            tooltipText: qsTr('cleanHistory')
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // History.
  // ---------------------------------------------------------------------------

  History {
    Layout.fillHeight: true
    Layout.fillWidth: true
    
    onEntryClicked:{
        historyView.fullPeerAddress=sipAddress
        historyView.peerAddress=sipAddress
        historyProxyModel.resetMessageCount()
    }

    proxyModel: HistoryProxyModel {
      id: historyProxyModel

      Component.onCompleted: {
          setEntryTypeFilter()
          resetMessageCount()
      }
    }
  }

}
