import QtQuick 2.7
import QtQuick.Layouts 1.3

import Clipboard 1.0
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
	property string peerAddress : getPeerAddress()
	property string localAddress : chatRoomModel?chatRoomModel.getLocalAddress() : defaultLocalAddress
	property string fullPeerAddress : getFullPeerAddress()
	property string fullLocalAddress : chatRoomModel?chatRoomModel.getFullLocalAddress() : defaultFullLocalAddress
	
	property int securityLevel : chatRoomModel ? chatRoomModel.securityLevel : 1
	
	property SipAddressObserver _sipAddressObserver: SipAddressesModel.getSipAddressObserver((fullPeerAddress?fullPeerAddress:peerAddress), (fullLocalAddress?fullLocalAddress:localAddress))
	
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
			return defaultPeerAddress
		}	
	}
	function getFullPeerAddress() {
		if(chatRoomModel) {
			if(chatRoomModel.groupEnabled || chatRoomModel.isSecure()) {
				return chatRoomModel.participants.addressesToString;
			}else {
				return chatRoomModel.sipAddress;
			}
		}else {
			return defaultFullPeerAddress;
		}	
	}
	
	// ---------------------------------------------------------------------------
	
	spacing: 0
	clip:false
	
	Component.onDestruction: _sipAddressObserver=null// Need to set it to null because of not calling destructor if not.
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
				presenceLevel: chatRoomModel && chatRoomModel.presenceStatus
				
				//username: Logic.getUsername()
				username: chatRoomModel?chatRoomModel.username:( conversation._sipAddressObserver ? UtilsCpp.getDisplayName(conversation._sipAddressObserver.peerAddress) : '')
				isOneToOne: chatRoomModel==undefined || chatRoomModel.isOneToOne==undefined || chatRoomModel.isOneToOne
			}
			
			Item{
				Layout.fillHeight: true
				Layout.fillWidth: true
				RowLayout{
					anchors.fill: parent
					spacing:0
					
					ColumnLayout{
						
						property int maximumContentWidth: contactBar.width
														  -(avatar.visible?avatar.width:0)
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
							visible: chatRoomModel && chatRoomModel.isMeAdmin && !usernameEdit.visible && !chatRoomModel.isOneToOne
							
							Icon{
								id:adminIcon
								icon : ConversationStyle.bar.status.adminStatusIcon
								overwriteColor: ConversationStyle.bar.status.adminStatusColor
								iconSize: ConversationStyle.bar.status.adminStatusIconSize
							}
							Text{
								anchors.verticalCenter: parent.verticalCenter
								//: 'Admin' : Admin(istrator)
								//~ Context One word title for describing the current admin status
								text: qsTr('adminStatus')
								color: ConversationStyle.bar.status.adminTextColor
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
							titleText: avatar.username
							titleClickable: chatRoomModel && chatRoomModel.isMeAdmin && !chatRoomModel.isOneToOne
							subtitleText: if(chatRoomModel) {
											  if(chatRoomModel.groupEnabled) {
												  return chatRoomModel.participants.displayNamesToString;
											  }else if(chatRoomModel.isSecure()) {
												  return chatRoomModel.participants.addressesToString;
											  }else
												  return SipAddressesModel.cleanSipAddress(chatRoomModel.sipAddress)
										  }else
											  return ''
							
							/*
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
							*/
							onTitleClicked: {
								if(!conversation.chatRoomModel.isReadOnly) {
									usernameEdit.visible = !usernameEdit.visible
									usernameEdit.forceActiveFocus()
								}
							}
						}
						Item{
							Layout.fillHeight: true
							Layout.fillWidth: true
							visible: chatRoomModel && chatRoomModel.isMeAdmin && !chatRoomModel.isOneToOne
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
							visible: conversation.chatRoomModel && !conversation.chatRoomModel.isReadOnly
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
						isCustom: true
						backgroundRadius: 1000
						colorSet: ConversationStyle.bar.actions.videoCall
						
						visible: SettingsModel.videoSupported && SettingsModel.outgoingCallsEnabled && SettingsModel.showStartVideoCallButton && !conversation.haveMoreThanOneParticipants
						enabled: !conversation.chatRoomModel.isReadOnly
						
						onClicked: CallsListModel.launchVideoCall(chatRoomModel.participants.addressesToString)
					}
					ActionButton {
						isCustom: true
						backgroundRadius: 1000
						colorSet: ConversationStyle.bar.actions.call
						
						visible: SettingsModel.outgoingCallsEnabled && !conversation.haveMoreThanOneParticipants
						enabled: !conversation.chatRoomModel.isReadOnly
						
						onClicked: CallsListModel.launchAudioCall(chatRoomModel.participants.addressesToString)
					}
					ActionButton {
						isCustom: true
						backgroundRadius: 1000
						colorSet: ConversationStyle.bar.actions.chat
						
						visible: SettingsModel.standardChatEnabled && SettingsModel.getShowStartChatButton() && !conversation.haveMoreThanOneParticipants && conversation.securityLevel != 1
						enabled: !conversation.chatRoomModel.isReadOnly
						
						onClicked: CallsListModel.launchChat(chatRoomModel.participants.addressesToString, 0)
					}
					ActionButton {
						isCustom: true
						backgroundRadius: 1000
						colorSet: ConversationStyle.bar.actions.chat
						visible: SettingsModel.secureChatEnabled && SettingsModel.getShowStartChatButton() && !conversation.haveMoreThanOneParticipants && conversation.securityLevel == 1
						enabled: !conversation.chatRoomModel.isReadOnly
						
						onClicked: CallsListModel.launchChat(chatRoomModel.participants.addressesToString, 1)
						Icon{
							icon:'secure_level_1'
							iconSize: parent.height/2
							anchors.top:parent.top
							anchors.horizontalCenter: parent.right
						}
					}
					
					ActionButton {
						id: groupCallButton
						property ConferenceInfoModel conferenceInfoModel: ConferenceInfoModel{}
						Connections{
							target: groupCallButton.conferenceInfoModel
							onConferenceCreated: {
								groupCallButton.toggled = false
							}
							onConferenceCreationFailed:{
								groupCallButton.toggled = false
							}
						}
						isCustom: true
						backgroundRadius: 1000
						colorSet: ConversationStyle.bar.actions.groupChat
						
						visible: conversation.chatRoomModel && conversation.haveMoreThanOneParticipants && SettingsModel.outgoingCallsEnabled && (SettingsModel.videoConferenceEnabled || conversation.haveLessThanMinParticipantsForCall)
						enabled: !conversation.chatRoomModel.isReadOnly
						
						onClicked:{
							if( SettingsModel.videoConferenceEnabled ){
								groupCallButton.toggled = true
								conferenceInfoModel.resetConferenceInfo();
								conferenceInfoModel.isScheduled = false
								conferenceInfoModel.subject = chatRoomModel.subject
							
								conferenceInfoModel.setParticipants(conversation.chatRoomModel.participants)
								conferenceInfoModel.inviteMode = 0;
								conferenceInfoModel.createConference(false)// TODO activate it when secure video conference is implemented
							}else{
								Logic.openConferenceManager({chatRoomModel:conversation.chatRoomModel, autoCall:true})
							}
						}
						//: "Call all chat room's participants" : tooltip on a button for calling all participant in the current chat room
						tooltipText: qsTr("groupChatCallButton")
					}
				}
				
				ActionBar {
					id:actionsBar
					anchors.verticalCenter: parent.verticalCenter
					
					ActionButton {
						id:dotButton
						isCustom: true
						backgroundRadius: 90
						colorSet: 	ConversationStyle.bar.actions.openMenu
						visible: true //conversationMenu.showGroupInfo || conversationMenu.showDevices || conversationMenu.showEphemerals
						toggled: conversationMenu.opened
						longPressedTimeout: 3000
						onPressed: {// Bug : Not working : Menu is still closed before pressing on button (even with closePolicy)
							if( conversationMenu.opened ) {
								conversationMenu.close()
							}else {
								conversationMenu.open()
							}
						}
						property string debugData: chatRoomModel ? 'Chat room ID:\n'+chatRoomModel.getFullPeerAddress()
													+'\nLocal account:\n'+chatRoomModel.getFullLocalAddress()
													: 'Chat room is null'
						onLongPressed:{
											if( SettingsModel.logsEnabled){
												conversationMenu.close()
												window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
													descriptionText: debugData,
													showButtonOnly: 1,
													buttonTexts: ['', 'COPY'],
													height:320,
												}, function (status) {
													Clipboard.text = debugData
												})
												}
									}
						
					}
				}
				Menu{
					id:conversationMenu
					x:mainBar.width-width
					y:mainBar.height
					menuStyle : MenuStyle.aux2
					
					property bool showGroupInfo: chatRoomModel && !chatRoomModel.isOneToOne
					property bool showDevices : conversation.securityLevel != 1
					property bool showEphemerals:  conversation.securityLevel != 1 // && chatRoomModel.isMeAdmin // Uncomment when session mode will be implemented
					property bool showScheduleMeeting: showGroupInfo && SettingsModel.conferenceEnabled
					
					MenuItem{
						id:contactMenu
						property bool editMode: conversation._sipAddressObserver && conversation._sipAddressObserver.contact
						text: editMode ? 
						//: 'View contact' : Item menu to view the contact in address book
										qsTr('conversationMenuViewContact')
						//: 'Add contact' : Item menu to add the contact to address book
										: qsTr('conversationMenuAddContact')
						iconMenu: editMode ? MenuItemStyle.contact.view : MenuItemStyle.contact.add
						iconSizeMenu: 40
						menuItemStyle : MenuItemStyle.aux2
						visible: conversation.chatRoomModel && SettingsModel.contactsEnabled && conversation.chatRoomModel.isOneToOne
						onTriggered: {
							window.setView('ContactEdit', {
													  sipAddress: conversation.getFullPeerAddress()
												  })
						}
						TooltipArea {
							text: Logic.getEditTooltipText()
						}
					}
					Rectangle{
						height:visible ? 1 : 0
						width:parent.width
						color: ConversationStyle.menu.separatorColor
						visible: groupInfoMenu.visible && contactMenu.visible
					}
					MenuItem{
						id:groupInfoMenu
						//: 'Group information' : Item menu to get information about the chat room
						text: qsTr('conversationMenuGroupInformations')
						iconMenu: MenuItemStyle.info.icon
						//iconSizeMenu: 40
						menuItemStyle : MenuItemStyle.aux2
						visible: conversationMenu.showGroupInfo
						onTriggered: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/InfoChatRoom.qml')
													   ,{chatRoomModel:chatRoomModel})
						}
					}
					Rectangle{
						height:visible ? 1 : 0
						width:parent.width
						color: ConversationStyle.menu.separatorColor
						visible: devicesMenuItem.visible && (contactMenu.visible || groupInfoMenu.visible)
					}
					MenuItem{
						id: devicesMenuItem
						//: "Conversation's devices" : Item menu to get all participant devices of the chat room
						text: qsTr('conversationMenuDevices')
						iconMenu: MenuItemStyle.devices.icon
						visible: conversationMenu.showDevices
						enabled: !conversation.chatRoomModel.isReadOnly
						iconSizeMenu: 40
						menuItemStyle : MenuItemStyle.aux2
						onTriggered: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/ParticipantsDevices.qml')
													   ,{chatRoomModel:chatRoomModel, window:window})
						}
					}
					Rectangle{
						height:visible ? 1 : 0
						width:parent.width
						color: ConversationStyle.menu.separatorColor
						visible: ephemeralMenuItem.visible && (contactMenu.visible || groupInfoMenu.visible || devicesMenuItem.visible)
					}
					MenuItem{
						id: ephemeralMenuItem
						//: 'Ephemeral messages' : Item menu to enable ephemeral mode
						text: qsTr('conversationMenuEphemeral')
						iconMenu: MenuItemStyle.ephemeral.icon
						iconSizeMenu: 40
						menuItemStyle : MenuItemStyle.aux2
						visible: conversationMenu.showEphemerals
						enabled: !conversation.chatRoomModel.isReadOnly
						onTriggered: {
							window.detachVirtualWindow()
							window.attachVirtualWindow(Qt.resolvedUrl('Dialogs/EphemeralChatRoom.qml')
													   ,{chatRoomModel:chatRoomModel})
						}
					}
					Rectangle{
						height:visible ? 1 : 0
						width:parent.width
						color: ConversationStyle.menu.separatorColor
						visible: scheduleMeetingMenuItem.visible && (contactMenu.visible || groupInfoMenu.visible || devicesMenuItem.visible || ephemeralMenuItem.visible)
					}
					MenuItem{
						id: scheduleMeetingMenuItem
						property ConferenceInfoModel conferenceInfoModel: ConferenceInfoModel{}
						
						//: 'Schedule a meeting' : Item menu to schedule a meeting with the chat participants.
						text: qsTr('conversationMenuScheduleMeeting')
						iconMenu: MenuItemStyle.scheduleMeeting.icon
						iconSizeMenu: 40
						menuItemStyle : MenuItemStyle.aux2
						visible: conversationMenu.showScheduleMeeting
						enabled: !conversation.chatRoomModel.isReadOnly
						onClicked: {
							conferenceInfoModel.resetConferenceInfo()
							conferenceInfoModel.isScheduled = true
							conferenceInfoModel.subject = chatRoomModel.subject
							conferenceInfoModel.setParticipants(conversation.chatRoomModel.participants)
							
							window.detachVirtualWindow()
							window.attachVirtualWindow(Utils.buildAppDialogUri('NewConference')
													   ,{conferenceInfoModel: scheduleMeetingMenuItem.conferenceInfoModel}
													   , function (status) {
														if( status){
															setView('Conferences')
														}
													   })
						}
					}
					
					Rectangle{
						height:visible ? 1 : 0
						width:parent.width
						color: ConversationStyle.menu.separatorColor
						visible: deleteMenuItem.visible && (contactMenu.visible || groupInfoMenu.visible || devicesMenuItem.visible || ephemeralMenuItem.visible || scheduleMeetingMenuItem.visible)
					}
					MenuItem{
						id: deleteMenuItem
						//: 'Delete history' : Item menu to delete the chat's history
						text: qsTr('conversationMenuDelete')
						iconMenu: MenuItemStyle.deleteEntry.icon
						iconSizeMenu: 40
						menuItemStyle : MenuItemStyle.aux2Error
						visible: true
						onTriggered: {
							Logic.removeAllEntries()
						}
						TooltipArea {
							text: qsTr('cleanHistory')
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
		visible: chatRoomModel && (!chatRoomModel.haveEncryption && SettingsModel.standardChatEnabled || chatRoomModel.haveEncryption && SettingsModel.secureChatEnabled)
		
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
			running: chatArea.tryingToLoadMoreEntries
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
				icon: (searchView.visible? 'close_custom': 'search_custom')
				iconSize: 30
				overwriteColor: ConversationStyle.bar.searchIconColor
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
			visible: true
			
			TextField {
				id:searchBar
				anchors {
					fill: parent
					margins: 0
				}
				width: parent.width-14
				icon: text != '' ? 'close_custom' : 'search_custom'
				overwriteColor: ConversationStyle.filters.iconColor
				//: 'Search in messages' : this is a placeholder when searching something in the timeline list
				placeholderText: qsTr('searchMessagesPlaceholder')
				
				onTextChanged: searchDelay.restart()
				font.pointSize: ConversationStyle.filters.pointSize
				
				Timer{
					id: searchDelay
					interval: 500
					running: false
					onTriggered: if( searchView.visible){
									 chatRoomProxyModel.filterText = searchBar.text
								 }
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
			
			function updateFilter(){
			if ( chatRoomModel && ((!chatRoomModel.haveEncryption && !SettingsModel.standardChatEnabled)
						|| (chatRoomModel.haveEncryption && !SettingsModel.secureChatEnabled)) ) {
					setEntryTypeFilter(ChatRoomModel.CallEntry)
				}
			}
			chatRoomModel: conversation.chatRoomModel
			peerAddress: conversation.peerAddress
			fullPeerAddress: conversation.fullPeerAddress
			fullLocalAddress: conversation.fullLocalAddress
			localAddress: conversation.localAddress// Reload is done on localAddress. Use this order
			
			onChatRoomModelChanged: updateFilter()
			Component.onCompleted: {
				updateFilter()
			}
		}
	}
	
	Connections {
		target: AccountSettingsModel
		onSipAddressChanged: {
			if (conversation.localAddress !== AccountSettingsModel.sipAddress) {
				window.setView('Home')
			}
		}
	}
	
	
}
