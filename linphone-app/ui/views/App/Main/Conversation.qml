import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Units 1.0

import ColorsList 1.0


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
	property bool haveMoreThanOneParticipants: chatRoomModel ? chatRoomModel.participants.count > 2 : false
	property bool haveLessThanMinParticipantsForCall: chatRoomModel ? chatRoomModel.participants.count <= 5 : false
	
	function getPeerAddress() {
		if(chatRoomModel) {
			if(chatRoomModel.groupEnabled || chatRoomModel.isSecure()) {
				return chatRoomModel.participants.addressesToString;
			}else {
				return chatRoomModel.sipAddress;
			}
		}else {
			return conversation.fullPeerAddress || conversation.peerAddress || '';
		}	
	}
	
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
				presenceLevel: chatRoomModel.presenceStatus
				
				//username: Logic.getUsername()
				username: chatRoomModel?chatRoomModel.username:Logic.getUsername()
				visible: !groupChat.visible				
			}
			
			Icon {
				id: groupChat
				
				Layout.preferredHeight: ConversationStyle.bar.groupChatSize
				Layout.preferredWidth: ConversationStyle.bar.groupChatSize
				
				icon:'chat_room'
				iconSize: ConversationStyle.bar.groupChatSize
				visible: !chatRoomModel.isOneToOne
			}
			Item{
				Layout.fillHeight: true
				Layout.fillWidth: true
				RowLayout{
					anchors.fill: parent
					spacing:0
					
					ColumnLayout{
					
						property int maximumContentWidth: contactBar.width
															-(avatar.visible?avatar.width:0)-(groupChat.visible?groupChat.width:0)
															-actionBar.width - (secureIcon.visible?secureIcon.width :0)
															-3*ConversationStyle.bar.spacing 
						Layout.fillHeight: true
						Layout.minimumWidth: 20
						Layout.maximumWidth: maximumContentWidth
						Layout.preferredWidth: contactDescription.contentWidth
						spacing: 5
						Row{
							Layout.topMargin: 15
							Layout.preferredHeight: implicitHeight
							Layout.alignment: Qt.AlignBottom
							visible:chatRoomModel.isMeAdmin && !usernameEdit.visible
							
							Icon{
								id:adminIcon
								icon : 'admin_selected'
								iconSize:14
							}
							Text{
								anchors.verticalCenter: parent.verticalCenter
								//: 'Admin' : Admin(istrator)
								//~ Context One word title for describing the current admin status
								text: qsTr('adminStatus')
								color: ColorsList.add("Conversation_admin_status", "af").color
								font.pointSize: Units.dp * 8
							}
						}
						
						ContactDescription {
							id:contactDescription
							Layout.minimumWidth: 20
							Layout.maximumWidth: parent.maximumContentWidth
							Layout.preferredWidth: contentWidth
							Layout.preferredHeight: contentHeight
							Layout.alignment: Qt.AlignTop | Qt.AlignLeft
							visible: !usernameEdit.visible 
							contactDescriptionStyle: ConversationStyle.bar.contactDescription
							username: avatar.username
							usernameClickable: chatRoomModel.isMeAdmin
							participants: if(chatRoomModel) {
											if(chatRoomModel.groupEnabled) {
												return chatRoomModel.participants.displayNamesToString;
											}else if(chatRoomModel.isSecure()) {
												return chatRoomModel.participants.addressesToString;
											}else
												return ''
										}else
											return ''
							sipAddress: {
								if(chatRoomModel) {
									if(chatRoomModel.groupEnabled) {
										return '';
									}else if(chatRoomModel.isSecure()) {
										return '';
									}else {
										return chatRoomModel.sipAddress;
									}
								}else {
									return conversation.fullPeerAddress || conversation.peerAddress || '';
								}
								
							}
							onUsernameClicked: {
													if(!conversation.hasBeenLeft) {
														usernameEdit.visible = !usernameEdit.visible
														usernameEdit.forceActiveFocus()
													}
												}
						}
						Item{
							Layout.fillHeight: true
							Layout.fillWidth: true
							visible: chatRoomModel.isMeAdmin
						}
					}
					Icon{
						id: secureIcon
						Layout.alignment: Qt.AlignVCenter
						visible: securityLevel != 1
						icon: securityLevel === 2?'secure_level_1': securityLevel===3? 'secure_level_2' : 'secure_level_unsafe'
						iconSize:30
						MouseArea{
							anchors.fill:parent
							visible: !conversation.hasBeenLeft
							onClicked : {
								window.detachVirtualWindow()
								window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/InfoEncryption.qml')
														   ,{securityLevel:securityLevel}
														   , function (status) {
															   if(status){
																   window.detachVirtualWindow()
																   window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/ParticipantsDevices.qml')
																							  ,{chatRoomModel:chatRoomModel
																								  , window:window})		
															   }
														   })
							}
						}
					}
					Item{//Spacer
						Layout.fillWidth: true
					}
				}
				ColumnLayout{
					id: usernameEdit
					anchors.fill: parent
					visible: false
					TextField{
						Layout.fillWidth: true
						text: avatar.username
						onEditingFinished: {
							chatRoomModel.subject = text
							usernameEdit.visible = false
						}
						font.bold: true
						onFocusChanged: if(!focus) usernameEdit.visible = false
					}
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
						visible: SettingsModel.videoSupported && SettingsModel.outgoingCallsEnabled && SettingsModel.showStartVideoCallButton && !conversation.haveMoreThanOneParticipants
						
						onClicked: CallsListModel.launchVideoCall(chatRoomModel.participants.addressesToString)
					}
					
					ActionButton {
						icon: 'call'
						visible: SettingsModel.outgoingCallsEnabled && !conversation.haveMoreThanOneParticipants
						
						onClicked: CallsListModel.launchAudioCall(chatRoomModel.participants.addressesToString)
					}
					ActionButton {
						icon: 'chat'
						visible: SettingsModel.chatEnabled && SettingsModel.getShowStartChatButton() && !conversation.haveMoreThanOneParticipants && conversation.securityLevel != 1
						
						onClicked: CallsListModel.launchChat(chatRoomModel.participants.addressesToString, 0)
					}
					ActionButton {
						icon: 'chat'
						visible: SettingsModel.chatEnabled && SettingsModel.getShowStartChatButton() && !conversation.haveMoreThanOneParticipants && conversation.securityLevel == 1 && UtilsCpp.hasCapability(conversation.peerAddress,  LinphoneEnums.FriendCapabilityLimeX3Dh)
						
						onClicked: CallsListModel.launchChat(chatRoomModel.participants.addressesToString, 1)
						Icon{
								icon:'secure_level_1'
								iconSize:15
								anchors.right:parent.right
								anchors.top:parent.top
								anchors.topMargin: -3
						}
					}
					
					ActionButton {
						icon: 'group_chat'
						visible: SettingsModel.outgoingCallsEnabled && conversation.haveMoreThanOneParticipants && conversation.haveLessThanMinParticipantsForCall && !conversation.hasBeenLeft
						
						onClicked: Logic.openConferenceManager({chatRoomModel:conversation.chatRoomModel, autoCall:true})
						TooltipArea {
							//: "Call all chat room's participants" : tooltip on a button for calling all participant in the current chat room
							text: qsTr("groupChatCallButton")
						}
					}
				}
				
				ActionBar {
					id:actionsBar
					anchors.verticalCenter: parent.verticalCenter
					
					ActionButton {
						icon: Logic.getEditIcon()
						iconSize: ConversationStyle.bar.actions.edit.iconSize
						visible: SettingsModel.contactsEnabled && !conversation.chatRoomModel.groupEnabled
						
						onClicked: window.setView('ContactEdit', {
													  sipAddress: conversation.getPeerAddress()
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
						visible: conversationMenu.showGroupInfo || conversationMenu.showDevices || conversationMenu.showEphemerals
						
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
					menuStyle : MenuStyle.aux2
					
					property bool showGroupInfo: !chatRoomModel.isOneToOne
					property bool showDevices : conversation.securityLevel != 1
					property bool showEphemerals:  conversation.securityLevel != 1 // && chatRoomModel.isMeAdmin // Uncomment when session mode will be implemented
					
					MenuItem{
						id:groupInfoMenu
						//: 'Group information' : Item menu to get information about the chat room
						text: qsTr('conversationMenuGroupInformations')
						iconMenu: (hovered ? 'menu_infos_selected' : 'menu_infos')
						iconSizeMenu: 25
						menuItemStyle : MenuItemStyle.aux2
						visible: conversationMenu.showGroupInfo
						onTriggered: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/InfoChatRoom.qml')
													   ,{chatRoomModel:chatRoomModel})
						}
					}
					Rectangle{
						id: separator1
						height:1
						width:parent.width
						color: ColorsList.add("Conversation_menu_separator", "u").color
						visible: groupInfoMenu.visible && devicesMenuItem.visible
					}
					MenuItem{
						id: devicesMenuItem
						//: "Conversation's devices" : Item menu to get all participant devices of the chat room
						text: qsTr('conversationMenuDevices')
						iconMenu: (hovered ? 'menu_devices_selected' : 'menu_devices' )
						visible: conversationMenu.showDevices
						iconSizeMenu: 25
						menuItemStyle : MenuItemStyle.aux2
						onTriggered: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/ParticipantsDevices.qml')
													   ,{chatRoomModel:chatRoomModel, window:window})
						}
					}
					Rectangle{
						id: separator2
						height:1
						width:parent.width
						color: ColorsList.add("Conversation_menu_separator", "u").color
						visible: ephemeralMenuItem.visible && (groupInfoMenu.visible || devicesMenuItem.visible)
					}
					MenuItem{
						id: ephemeralMenuItem
						//: 'Ephemeral messages' : Item menu to enable ephemeral mode
						text: qsTr('conversationMenuEphemeral')
						iconMenu: (hovered ? 'menu_ephemeral_selected' : 'menu_ephemeral')
						iconSizeMenu: 25
						menuItemStyle : MenuItemStyle.aux2
						visible: conversationMenu.showEphemerals
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
			id: filterButtons
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
		BusyIndicator{
			id: chatLoading
			width: 20
			height: 20
			anchors.left: filterButtons.right
			anchors.leftMargin: 50
			anchors.verticalCenter: parent.verticalCenter
			//anchors.horizontalCenter: parent.horizontalCenter
			visible: chatArea.tryingToLoadMoreEntries
		}
			
		// -------------------------------------------------------------------------
		// Search.
		// -------------------------------------------------------------------------
		MouseArea{
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.rightMargin: 10
			anchors.topMargin: 10
			anchors.bottomMargin: 10
			width: 30
			Icon{
				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter: parent.horizontalCenter
				icon: (searchView.visible? 'close': 'search')
				iconSize: 20
			}
			onClicked: {
				searchView.visible = !searchView.visible
				chatRoomProxyModel.filterText = searchView.text
			}
		}
		Rectangle{
			id:searchView
			property alias text: searchBar.text
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.left : chatLoading.right
			anchors.rightMargin: 10
			anchors.leftMargin: 50
			anchors.topMargin: 10
			anchors.bottomMargin: 10
			visible: false
			
			TextField {
				id:searchBar
				anchors {
					fill: parent
					margins: 1
				}
				width: parent.width-14
				icon: 'textfield_close'
				persistentIcon: true
				//: 'Search in messages' : this is a placeholder when searching something in the timeline list
				placeholderText: qsTr('searchMessagesPlaceholder')
				
				onTextChanged: chatRoomProxyModel.filterText = text
				onIconClicked: {
					searchView.visible = false
					chatRoomProxyModel.filterText = ''
				}
			}
			
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
			}
			chatRoomModel: conversation.chatRoomModel
			peerAddress: conversation.peerAddress
			fullPeerAddress: conversation.fullPeerAddress
			fullLocalAddress: conversation.fullLocalAddress
			localAddress: conversation.localAddress// Reload is done on localAddress. Use this order
		}
	}
	
	Connections {
		target: AccountSettingsModel
		onAccountSettingsUpdated: {
			if (conversation.localAddress !== AccountSettingsModel.sipAddress) {
				window.setView('Home')
			}
		}
	}
	
	
}
