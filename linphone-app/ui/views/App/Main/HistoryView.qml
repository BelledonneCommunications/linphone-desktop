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
	
	property var entry
	property string peerAddress : entry ? entry.sipAddress : ''
	property string fullPeerAddress : entry ? entry.sipAddress : ''
	
	
	property var _sipAddressObserver: peerAddress?SipAddressesModel.getSipAddressObserver((fullPeerAddress?fullPeerAddress:peerAddress), ''):null
	
	onEntryChanged: historyProxyModel.resetMessageCount()
	// ---------------------------------------------------------------------------
	
	spacing: 0
	Component.onDestruction: _sipAddressObserver=null// Need to set it to null because of not calling destructor if not.
	// ---------------------------------------------------------------------------
	// Contact bar.
	// ---------------------------------------------------------------------------
	
	Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: peerAddress?HistoryViewStyle.bar.height:HistoryViewStyle.bar.height/2
		
		color: HistoryViewStyle.bar.backgroundColor.color
		
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
				
				image: peerAddress && historyView._sipAddressObserver && historyView._sipAddressObserver.contact? historyView._sipAddressObserver.contact.avatar : null
				
				presenceLevel: historyView._sipAddressObserver?Presence.getPresenceLevel(
																	historyView._sipAddressObserver.presenceStatus
																	):null
				presenceTimestamp: historyView._sipAddressObserver && historyView._sipAddressObserver.contact ? historyView._sipAddressObserver.contact.presenceTimestamp :null
				
				username: historyView.entry && historyView.entry.wasConference
							? historyView.entry.title
							: peerAddress && historyView._sipAddressObserver
								? UtilsCpp.getDisplayName(historyView._sipAddressObserver.peerAddress)
								: null
				visible: peerAddress
				isOneToOne: !historyView.entry || !historyView.entry.wasConference
			}
			
			ContactDescription {
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				subtitleText: historyView.entry && historyView.entry.wasConference
								? ''
								: UtilsCpp.toDisplayString(SipAddressesModel.cleanSipAddress(historyView.peerAddress), SettingsModel.sipDisplayMode)
				subtitleColor: HistoryViewStyle.bar.description.subtitleColor.color
				titleText: avatar.username
				titleColor: HistoryViewStyle.bar.description.titleColor.color
				visible:peerAddress
			}
			
			Row {
				Layout.fillHeight: true
				
				spacing: HistoryViewStyle.bar.actions.spacing
				ActionBar {
					anchors.verticalCenter: parent.verticalCenter
					iconSize: HistoryViewStyle.bar.actions.call.iconSize
					visible: historyView.entry || false
					
					ActionButton {
						isCustom: true
						backgroundRadius: 90
						colorSet: HistoryViewStyle.videoCall
						visible: peerAddress && SettingsModel.videoAvailable && SettingsModel.outgoingCallsEnabled && SettingsModel.showStartVideoCallButton
						
						onClicked: CallsListModel.launchVideoCall(historyView.peerAddress)
					}
					
					ActionButton {
						isCustom: true
						backgroundRadius: 90
						colorSet: HistoryViewStyle.call
						visible: peerAddress && SettingsModel.outgoingCallsEnabled
						
						onClicked: CallsListModel.launchAudioCall(historyView.peerAddress)
					}
					ActionButton {
						isCustom: true
						backgroundRadius: 90
						colorSet: HistoryViewStyle.chat
						
						visible: peerAddress && SettingsModel.standardChatEnabled && SettingsModel.getShowStartChatButton() && !historyView.entry.wasConference
						
						onClicked: CallsListModel.launchChat(historyView.peerAddress, 0)
					}
					ActionButton {
						isCustom: true
						backgroundRadius: 1000
						colorSet: HistoryViewStyle.chat
						visible: peerAddress && SettingsModel.secureChatEnabled && SettingsModel.getShowStartChatButton() && !historyView.entry.wasConference
						onClicked: CallsListModel.launchChat(historyView.peerAddress, 1)
						Icon{
							icon:'secure_level_1'
							iconSize: parent.height/2
							anchors.top:parent.top
							anchors.horizontalCenter: parent.right
						}
					}
				}
				
				ActionBar {
					anchors.verticalCenter: parent.verticalCenter
					
					ActionButton {
						isCustom: true
						backgroundRadius: 4
						colorSet: historyView._sipAddressObserver && historyView._sipAddressObserver.contact ? ConversationStyle.bar.actions.edit.viewContact : ConversationStyle.bar.actions.edit.addContact
						iconSize: HistoryViewStyle.bar.actions.edit.iconSize
						visible: SettingsModel.contactsEnabled && historyView.entry ? !historyView.entry.wasConference : false
						
						onClicked: window.setView('ContactEdit', { sipAddress: historyView.peerAddress })
						tooltipText: peerAddress?Logic.getEditTooltipText():''
					}
					
					ActionButton {
						isCustom: true
						backgroundRadius: 90
						colorSet: HistoryViewStyle.deleteAction
						
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
			historyView.entry = entry
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
