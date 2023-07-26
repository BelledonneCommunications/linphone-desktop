import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Units 1.0
import UtilsCpp 1.0
import ColorsList 1.0

// =============================================================================

DialogPlus {
	id: conferenceManager
	property ChatRoomModel chatRoomModel
	
	readonly property int minParticipants: 1
	
	buttons: [
		TextButtonA {
			//: 'Cancel' : Cancel button
			text: qsTr('cancelButton')
			capitalization: Font.AllUppercase
			
			onClicked: exit(0)
		},
		TextButtonB {
			enabled: selectedParticipants.count >= conferenceManager.minParticipants && subject.text != '' && AccountSettingsModel.conferenceUri != ''
			//: 'Launch' : Start button
			text: qsTr('startButton')
			capitalization: Font.AllUppercase
			
			onClicked: {
				if(CallsListModel.createChatRoom(subject.text, secureSwitch.checked, selectedParticipants.getParticipants(), true ))
					exit(1)
			}
			TooltipArea{
				visible: AccountSettingsModel.conferenceUri == '' || subject.text == '' || selectedParticipants.count < conferenceManager.minParticipants
				maxWidth: participantView.width
				delay:0
				text: {
						var txt = '\n';
						if( subject.text == '')
							//: 'You need to fill a subject.' : Tooltip to warn a user on missing field.
							txt ='- ' + qsTr('missingSubject') + '\n'
						if( selectedParticipants.count < conferenceManager.minParticipants)
						//: 'You need at least %1 participant.' : Tooltip to warn a user that there are not enough participants for the chat creation.
							txt += '- ' + qsTr('missingParticipants', '', conferenceManager.minParticipants).arg(conferenceManager.minParticipants) + '\n'
						if( AccountSettingsModel.conferenceUri == '')
						//: 'You need to set the conference URI in your account settings to create a conference based chat room.' : Tooltip to warn the user that a setting is missong in its configuration.
							txt += '- ' + qsTr('missingConferenceURI') + '\n'
						return txt;
					}
			}
		}
	]
	
	buttonsAlignment: Qt.AlignRight
	//: 'Start a chat room' : Title of a popup about creation of a chat room
	title:qsTr('newChatRoomTitle')
	
	height: 500
	width: 800
	
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
				spacing: 20
				
				Item{
					Layout.fillHeight: true
				}
				ColumnLayout{
					Layout.fillWidth: true
					Layout.topMargin:15
					spacing:4
					visible: SettingsModel.secureChatEnabled && SettingsModel.standardChatEnabled
					Text {
						Layout.fillWidth: true
						//: 'Would you like to encrypt your chat?' : Ask about setting the chat room as secured.
						text:qsTr('askEncryption')
						color: NewChatRoomStyle.askEncryptionColor.color
						font.pointSize: Units.dp * 11
						font.weight: Font.DemiBold
					}
					Item{
						Layout.fillWidth: true
						Layout.preferredHeight: 50
						Icon{
							id:secureOff
							anchors.left:parent.left
							anchors.leftMargin : 5
							anchors.verticalCenter: parent.verticalCenter
							width:20
							height:20
							icon: 'secure_off'
							iconSize:20
						}
						Switch{
							id:secureSwitch
							anchors.left:secureOff.right
							anchors.leftMargin : 5
							anchors.verticalCenter: parent.verticalCenter
							width:50
							enabled:true
							checked: !SettingsModel.standardChatEnabled && SettingsModel.secureChatEnabled 
							
							onClicked: {
								var newCheck = checked
								if(SettingsModel.standardChatEnabled && checked || SettingsModel.secureChatEnabled && !checked)
										newCheck = !checked;
/*	Uncomment if we need to remove participants that doesn't have the capability (was commented because we cannot get capabilities in all cases)
									if(newCheck){	// Remove all participants that have not the capabilities
										var participants = selectedParticipants.getParticipants()
										for(var index in participants){
											if(!smartSearchBar.isUsable(participants[index].sipAddress))
												participantView.removeParticipant(participants[index])
										}
									}
*/
								checked = newCheck;
							}
							indicatorStyle: SwitchStyle.aux
						}
						Icon{
							id:secureOn
							anchors.left:secureSwitch.right
							anchors.leftMargin : 15
							anchors.verticalCenter: parent.verticalCenter
							width:20
							height:20
							icon: 'secure_on'
							iconSize:20
						}
					}
				}
				
				Item{
					Layout.fillHeight:true
				}
				ColumnLayout {
					Layout.fillWidth: true
					spacing:10
					RowLayout{
						Icon{
								id:defaultSecure
								Layout.alignment: Qt.AlignCenter
								Layout.preferredHeight: visible? 20 : 0
								Layout.preferredWidth: visible? 20 : 0
								icon: 'secure_on'
								iconSize:20
								visible: SettingsModel.secureChatEnabled && !SettingsModel.standardChatEnabled
							}
						Text{
							textFormat: Text.RichText
							//: 'Subject' : Label of a text field about the subject of the chat room
							text :qsTr('subjectLabel') +'<span style="color:red">*</span>'
							color: NewChatRoomStyle.subjectTitleColor.color
							font.pointSize: Units.dp * 11
							font.weight: Font.DemiBold
						}
					}
					TextField {
						id:subject
						Layout.fillWidth: true
						Layout.rightMargin: 15
						//: 'Give a subject' : Placeholder in a form about setting a subject
						placeholderText : qsTr('subjectPlaceholder')
						text:(chatRoomModel?chatRoomModel.getSubject():'')
						Keys.onEnterPressed:  nextItemInFocusChain().forceActiveFocus()
						Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
						TooltipArea{
							//: 'Current subject of the Chat Room. It cannot be empty'
							//~ Tooltip Explanation about the subject of the chat room
							text : qsTr('subjectTooltip')
						}
					}
					
				}
				Item{
					Layout.fillHeight:true
				}
				ColumnLayout {
					Layout.fillWidth: true
					Layout.fillHeight: true
					spacing:20
					Text{
						//: 'Last contacts' : Header for showing last contacts
						text : qsTr('LastContactsTitle')
						color: NewChatRoomStyle.recentContactTitleColor.color
						font.pointSize: Units.dp * 11
						font.weight: Font.DemiBold
					}
					RowLayout{
						Layout.fillWidth: true
						Layout.fillHeight : true
						spacing:0
						
						Repeater{
							id:lastContacts
							property int reloadCount : 0
							model:TimelineListModel.getLastChatRooms(5)
							delegate :
								Item{
								//Layout.fillHeight: true
								Layout.preferredHeight: 60
								Layout.preferredWidth: 50 + avatar2.height/2
								ColumnLayout{
									anchors.fill:parent
									Avatar{
										id:avatar2
										Layout.preferredHeight: 50
										Layout.preferredWidth: 50
										Layout.alignment: Qt.AlignCenter
										username: modelData.username
										image:modelData.avatar
										Icon{
											property int securityLevel : 2
											anchors.top:parent.top
											anchors.horizontalCenter: parent.right
											visible: SettingsModel.secureChatEnabled && UtilsCpp.hasCapability(modelData.sipAddress, LinphoneEnums.FriendCapabilityLimeX3Dh, true) 
											icon: 'secure_on'
											iconSize: parent.height/2
										}
									}
									Text{
										Layout.fillHeight: true
										Layout.preferredWidth: 60
										Layout.alignment: Qt.AlignVCenter | Qt.AlignTop
										maximumLineCount: 5
										wrapMode:Text.Wrap
										text: modelData.username
										verticalAlignment: Text.AlignTop
										horizontalAlignment: Text.AlignHCenter
										
										font.weight: Font.DemiBold
										lineHeight: 0.8
										color: NewChatRoomStyle.recentContactUsernameColor.color
										font.pointSize: Units.dp * 9
										clip:false
									}
								}
								
								Rectangle{
									id:mask
									anchors.fill:parent
									//anchors.topMargin: -5
									color:'white'
									opacity: 0.5
									visible: smartSearchBar.isIgnored(modelData.sipAddress)
									Connections{// Workaround for refreshing data on events
										target:lastContacts
										onReloadCountChanged: {
											mask.visible=smartSearchBar.isIgnored(modelData.sipAddress) 
										}
									}
								}
								MouseArea{
									anchors.fill:parent
									visible:!mask.visible
									onClicked: {
										selectedParticipants.addAddress(modelData.sipAddress)
										smartSearchBar.addAddressToIgnore(modelData.sipAddress);
										++lastContacts.reloadCount
									}
								}
							}
						}
					}
				}
				Item{
					Layout.fillHeight: true
					Layout.fillWidth: true
				}
			}
		}
		// -------------------------------------------------------------------------
		// See and remove selected addresses.
		// -------------------------------------------------------------------------
		ColumnLayout{
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.topMargin: 10
			Layout.bottomMargin: 10
			Rectangle{
				Layout.fillHeight: true
				Layout.fillWidth: true
				border.width: 1
				border.color: NewChatRoomStyle.addressesBorderColor.color
				
				ColumnLayout {
					anchors.fill: parent
					anchors.topMargin: 15
					anchors.leftMargin: 10
					anchors.rightMargin: 10
					spacing: 0
					
					SmartSearchBar {
						id: smartSearchBar
						
						Layout.fillWidth: true
						Layout.topMargin: ConferenceManagerStyle.columns.selector.spacing
						
						showHeader:false
						
						maxMenuHeight: MainWindowStyle.searchBox.maxHeight
						//: 'Select participants' : Placeholder for a search on participant to add them in selection.
						placeholderText: qsTr('participantSelectionPlaceholder')
						//: 'Search in your contacts or add a custom one to the chat room.'
						tooltipText: qsTr('participantSelectionTooltip')
						
						actions:[{
								colorSet: NewChatRoomStyle.addParticipant,
								secure: SettingsModel.secureChatEnabled,
								visible: true,
								secureIconVisibleHandler : function(entry) {
									return entry && entry.sipsipAddress ? UtilsCpp.hasCapability(entry.sipAddress,  LinphoneEnums.FriendCapabilityLimeX3Dh, true) : false
 								},
								handler: function (entry) {
									selectedParticipants.addAddress(entry.sipAddress)
									smartSearchBar.addAddressToIgnore(entry.sipAddress);
									++lastContacts.reloadCount
								},
							}]
						
						onEntryClicked: {
								selectedParticipants.addAddress(entry.sipAddress)
								smartSearchBar.addAddressToIgnore(entry.sipAddress);
								++lastContacts.reloadCount
						}
					}
					Text{
						Layout.preferredHeight: 20
						Layout.rightMargin: 65
						Layout.alignment: Qt.AlignRight | Qt.AlignBottom
						Layout.topMargin: ConferenceManagerStyle.columns.selector.spacing
						//: 'Admin' : Admin(istrator)
						//~ one word for admin status
						text : qsTr('adminStatus')
						
						color: NewChatRoomStyle.addressesAdminColor.color
						font.pointSize: Units.dp * 11
						font.weight: Font.Light
						visible: participantView.count > 0
						
					}
					ScrollableListViewField {
						Layout.fillHeight: true
						Layout.fillWidth: true
						Layout.bottomMargin: 5
						
						textFieldStyle: TextFieldStyle.unbordered
						
						ParticipantsView {
							id: participantView
							anchors.fill: parent
							
							showSubtitle:false
							showSwitch : true
							showSeparator: false
							isSelectable: false
							showInvitingIndicator: false
							function removeParticipant(entry){
										smartSearchBar.removeAddressToIgnore(entry.sipAddress)
										selectedParticipants.removeModel(entry)
										++lastContacts.reloadCount
							}
							
							
							actions: [{
									colorSet: NewChatRoomStyle.removeParticipant,
									secure:0,
									visible:true,
									//: 'Remove this participant from the selection' : Explanation about removing participant from a selection
									//~ Tooltip This is a tooltip
									tooltipText: qsTr('removeParticipantSelection'),
									handler: function (entry) {
										removeParticipant(entry)
									}
								}]
							
							genSipAddress: ''
							
							model: ParticipantProxyModel {
								id:selectedParticipants
								chatRoomModel:null
								
							}
							// it's best to toggle all contacts instead of one (that will be reset after loadng another address)
							onEntryClicked: participantView.showSubtitle = !participantView.showSubtitle
						}
					}
				}
			}
			Item{
				Layout.fillWidth: true
				Layout.preferredHeight: 20
				Text{
					anchors.fill:parent
					textFormat: Text.RichText
					//: 'Required' : Word relative to a star to explain that it is a requirement (Field form)
					text : '<span style="color:red">*</span> '+qsTr('requiredField')
					color: NewChatRoomStyle.requiredColor.color
					font.pointSize: Units.dp * 8
				}
			}
		}
	}
}
