import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

import 'Conversation.js' as Logic

// =============================================================================

ColumnLayout  {
	id: conversation
	// 1) chatRoomModel : chat + calls + conference
	// 2) no chatRoomModel : calls  
	property string defaultPeerAddress
	property string defaultLocalAddress
	property string defaultFullPeerAddress
	property string defaultFullLocalAddress
	
	
	property ChatRoomModel chatRoomModel
	property string peerAddress : chatRoomModel?chatRoomModel.getPeerAddress() : defaultPeerAddress
	property string localAddress : chatRoomModel?chatRoomModel.getLocalAddress() : defaultLocalAddress
	property string fullPeerAddress : chatRoomModel?chatRoomModel.getFullPeerAddress() : defaultFullPeerAddress
	property string fullLocalAddress : chatRoomModel?chatRoomModel.getFullLocalAddress() : defaultFullLocalAddress
	
	property int securityLevel : chatRoomModel ? chatRoomModel.securityLevel : 1
	
	readonly property var _sipAddressObserver: SipAddressesModel.getSipAddressObserver((fullPeerAddress?fullPeerAddress:peerAddress), (fullLocalAddress?fullLocalAddress:localAddress))
	
	// ---------------------------------------------------------------------------
	
	spacing: 0
	clip:false
	
	// ---------------------------------------------------------------------------
	// Contact bar.
	// ---------------------------------------------------------------------------
	
	Rectangle {
		id:mainBar
		Layout.fillWidth: true
		Layout.preferredHeight: ConversationStyle.bar.height
		
		color: ConversationStyle.bar.backgroundColor
		clip:false
		
		RowLayout {
			id:contactBar
			anchors {
				fill: parent
				leftMargin: ConversationStyle.bar.leftMargin
				rightMargin: ConversationStyle.bar.rightMargin
			}
			spacing: ConversationStyle.bar.spacing
			
			Avatar {
				id: avatar
				
				Layout.preferredHeight: ConversationStyle.bar.avatarSize
				Layout.preferredWidth: ConversationStyle.bar.avatarSize
				
				image: Logic.getAvatar()
				/*
				presenceLevel: Presence.getPresenceLevel(
								   conversation._sipAddressObserver.presenceStatus
								   )*/
				presenceLevel: chatRoomModel.presenceStatus
				
				//username: Logic.getUsername()
				username: chatRoomModel?chatRoomModel.username:Logic.getUsername()
			}
			RowLayout{
				Layout.fillHeight: true
				Layout.fillWidth: true
				spacing:0
				ContactDescription {
					Layout.fillHeight: true
					Layout.minimumWidth: 20
					Layout.maximumWidth: contactBar.width-avatar.width-actionBar.width-3*ConversationStyle.bar.spacing
					Layout.preferredWidth: contentWidth
					//sipAddress: conversation.peerAddress
					sipAddressColor: ConversationStyle.bar.description.sipAddressColor
					username: avatar.username
					usernameColor: ConversationStyle.bar.description.usernameColor
					
					sipAddress: (chatRoomModel?
										  (chatRoomModel.groupEnabled || chatRoomModel.isSecure()?
											  chatRoomModel.participants.usernamesToString()
										: chatRoomModel.sipAddress
									 ):conversation.sipAddress || conversation.fullPeerAddress || conversation.peerAddress || '')
				}
				Icon{
					Layout.alignment: Qt.AlignVCenter
					visible: securityLevel != 1
					icon: securityLevel === 2?'secure_level_1': securityLevel===3? 'secure_level_2' : 'secure_level_unsafe'
					iconSize:30
				}
				Item{//Spacer
					Layout.fillWidth: true
				}
			}
			
			Row {
				id:actionBar
				Layout.fillHeight: true
				
				spacing: ConversationStyle.bar.actions.spacing
				
				ActionBar {
					anchors.verticalCenter: parent.verticalCenter
					iconSize: ConversationStyle.bar.actions.call.iconSize
					
					ActionButton {
						icon: 'video_call'
						visible: SettingsModel.videoSupported && SettingsModel.outgoingCallsEnabled && SettingsModel.showStartVideoCallButton
						
						onClicked: CallsListModel.launchVideoCall(conversation.peerAddress)
					}
					
					ActionButton {
						icon: 'call'
						visible: SettingsModel.outgoingCallsEnabled
						
						onClicked: CallsListModel.launchAudioCall(conversation.peerAddress)
					}/*
		  ActionButton {
			icon: 'call_chat_unsecure'
			onClicked: {
				window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/ManageChatRoom.qml'), {
				//window.setView('Dialogs/ManageChatRoom', {
										   chatRoomModel:conversation.chatRoomModel
									   })}
		  }*/
				}
				
				ActionBar {
					id:actionsBar
					anchors.verticalCenter: parent.verticalCenter
					
					ActionButton {
						icon: Logic.getEditIcon()
						iconSize: ConversationStyle.bar.actions.edit.iconSize
						visible: SettingsModel.contactsEnabled
						
						onClicked: window.setView('ContactEdit', {
													  sipAddress: conversation.peerAddress
												  })
						TooltipArea {
							text: Logic.getEditTooltipText()
						}
					}
					
					ActionButton {
						icon: 'delete'
						iconSize: ConversationStyle.bar.actions.edit.iconSize
						
						onClicked: Logic.removeAllEntries()
						
						TooltipArea {
							text: qsTr('cleanHistory')
						}
					}
					ActionButton {
						id:dotButton
						icon: 'menu_vdots'
						iconSize: ConversationStyle.bar.actions.edit.iconSize
						//autoIcon: true
						
						onClicked: {
							conversationMenu.open()
						}
						
					}
				}
				Menu{
					id:conversationMenu
					x:mainBar.width-width
					y:mainBar.height
					width:250
					MenuItem{
						text:'Groupe informations'
						iconMenu: 'menu_infos'
						iconSizeMenu: 20
						onTriggered: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/InfoChatRoom.qml')
													   ,{chatRoomModel:chatRoomModel})
						}
					}
					MenuItem{
						text:"Conversation's devices"
						iconMenu: 'menu_devices'
						iconSizeMenu: 20
						onTriggered: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/ParticipantsDevices.qml')
													   ,{chatRoomModel:chatRoomModel})
						}
					}
					MenuItem{
						text:'Ephemeral messages'
						iconMenu: 'menu_ephemeral'
						iconSizeMenu: 20
						onTriggered: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/EphemeralChatRoom.qml')
													   ,{chatRoomModel:chatRoomModel})
						}
					}
				}
			}
		}
		
		
	}
	
	// ---------------------------------------------------------------------------
	// Messages/Calls filters.
	// ---------------------------------------------------------------------------
	
	Borders {
		id:filtersBar
		Layout.fillWidth: true
		Layout.preferredHeight: active ? ConversationStyle.filters.height : 0
		
		borderColor: ConversationStyle.filters.border.color
		bottomWidth: ConversationStyle.filters.border.bottomWidth
		color: ConversationStyle.filters.backgroundColor
		topWidth: ConversationStyle.filters.border.topWidth
		visible: SettingsModel.chatEnabled
		
		ExclusiveButtons {
			anchors {
				left: parent.left
				leftMargin: ConversationStyle.filters.leftMargin
				verticalCenter: parent.verticalCenter
			}
			
			texts: [
				qsTr('displayCallsAndMessages'),
				qsTr('displayCalls'),
				qsTr('displayMessages')
			]
			
			onClicked: Logic.updateChatFilter(button)
		}
	}
	
	// ---------------------------------------------------------------------------
	// Chat.
	// ---------------------------------------------------------------------------
	
	Chat {
		id:chatArea
		Layout.fillHeight: true
		Layout.fillWidth: true
		
		proxyModel: ChatRoomProxyModel {
			id: chatRoomProxyModel
			
			Component.onCompleted: {
				if (!SettingsModel.chatEnabled) {
					setEntryTypeFilter(ChatRoomModel.CallEntry)
				}
				resetMessageCount()
			}
			chatRoomModel: conversation.chatRoomModel
			peerAddress: conversation.peerAddress
			fullPeerAddress: conversation.fullPeerAddress
			fullLocalAddress: conversation.fullLocalAddress
			localAddress: conversation.localAddress// Reload is done on localAddress. Use this order
		}
	}
	/*
  Connections {
	target: SettingsModel
	onChatEnabledChanged: chatRoomProxyModel.setEntryTypeFilter(status ? ChatRoomModel.GenericEntry : ChatRoomModel.CallEntry)
  }*/
	
	Connections {
		target: AccountSettingsModel
		onAccountSettingsUpdated: {
			if (conversation.localAddress !== AccountSettingsModel.sipAddress) {
				window.setView('Home')
			}
		}
	}
	
	
}
