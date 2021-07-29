import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
//import LinphoneUtils 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Common.Styles 1.0
import Colors 1.0
import Units 1.0
import UtilsCpp 1.0

// =============================================================================

DialogPlus {
	id: conferenceManager
	property ChatRoomModel chatRoomModel
	
	readonly property int maxParticipants: 20
	readonly property int minParticipants: 1
	
	buttons: [
		TextButtonA {
			text: 'CANCEL'
			
			onClicked: exit(0)
		},
		TextButtonB {
			//enabled: toAddView.count >= conferenceManager.minParticipants
			text: 'LANCER'
			
			onClicked: {
				if(CallsListModel.createChatRoom(subject.text, secureSwitch.checked, selectedParticipants.getParticipants() ))
					exit(1)
			}
		}
	]
	
	buttonsAlignment: Qt.AlignRight
	title:'Lancer un chat de groupe'
	
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
					Text {
						Layout.fillWidth: true
						text:'Would you like to encrypt your chat?'
						color: Colors.g
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
							//Layout.preferredWidth: 50
							enabled:true
							onClicked: checked = !checked
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
					//Layout.preferredHeight: 90
					spacing:10
					Text{
						textFormat: Text.RichText
						text :'Nom du groupe' +'<span style="color:red">*</span>'
						color: Colors.g
						font.pointSize: Units.dp * 11
						font.weight: Font.DemiBold
					}
					TextField {
						id:subject
						Layout.fillWidth: true
						Layout.rightMargin: 15
						placeholderText :"Nommer le groupe"
						text:(chatRoomModel?chatRoomModel.getSubject():'')
						Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
						//error : text == ''
						TooltipArea{
							text : 'Current subject of the ChatRoom. It cannot be empty'
						}
					}
					
				}
				Item{
					Layout.fillHeight:true
				}
				ColumnLayout {
					Layout.fillWidth: true
					Layout.fillHeight: true
					//Layout.preferredHeight: 200
					spacing:20
					Text{
						text :'Contacts récents'
						color: Colors.g
						font.pointSize: Units.dp * 11
						font.weight: Font.DemiBold
					}
					RowLayout{
						Layout.fillWidth: true
						Layout.fillHeight : true
						spacing:10
						
						Repeater{
							id:lastContacts
							property int reloadCount : 0
							model:TimelineListModel.getLastChatRooms(5)
							//[{username:'Danyl Robertson'}, {username:'Toto harrytop'}]
							delegate :
								Item{
								Layout.fillHeight: true
								Layout.preferredWidth: 60
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
											anchors.right: parent.right
											anchors.top:parent.top
											anchors.topMargin: -5
											visible: UtilsCpp.hasCapability(modelData.sipAddress, LinphoneEnums.FriendCapabilityLimeX3Dh) 
											icon: 'secure_on'
											iconSize:20
											Rectangle{
												id:secureMask
												anchors.fill:parent
												color:'white'
												opacity: 0.5
												visible: smartSearchBar.isIgnored(modelData.sipAddress)
												Connections{// Workaround for refreshing data on events
													target:lastContacts
													onReloadCountChanged: {
														secureMask.visible=smartSearchBar.isIgnored(modelData.sipAddress) 
													}
												}
											}
										}
									}
									Text{
										Layout.fillHeight: true
										//Layout.maximumHeight: 100
										Layout.preferredWidth: 60
										Layout.alignment: Qt.AlignVCenter | Qt.AlignTop
										maximumLineCount: 5
										wrapMode:Text.Wrap
										text: modelData.username
										verticalAlignment: Text.AlignTop
										horizontalAlignment: Text.AlignHCenter
										
										font.weight: Font.DemiBold
										lineHeight: 0.8
										color: Colors.g
										font.pointSize: Units.dp * 9
										clip:false
									}
								}
								
								Rectangle{
									id:mask
									anchors.fill:parent
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
										selectedParticipants.add(modelData.sipAddress)
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
		/*
		ScrollableListViewField {
		  Layout.fillHeight: true
		  Layout.fillWidth: true
		  
		  readOnly: toAddView.count >= conferenceManager.maxParticipants
		  
		  SipAddressesView {
			anchors.fill: parent
			
			actions: [{
			  icon: 'transfer',
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
*/
		// -------------------------------------------------------------------------
		// Separator.
		// -------------------------------------------------------------------------
		/*
	Rectangle {
	  Layout.fillHeight: true
	  Layout.leftMargin: ConferenceManagerStyle.columns.separator.leftMargin
	  Layout.preferredWidth: ConferenceManagerStyle.columns.separator.width
	  Layout.rightMargin: ConferenceManagerStyle.columns.separator.rightMargin
	  
	  color: ConferenceManagerStyle.columns.separator.color
	}
*/
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
				border.color: "black"
				
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
						placeholderText: 'toto'
						tooltipText: 'tooltip'
						actions:[{
								icon: 'add_participant',
								secure:0,
								handler: function (entry) {
									selectedParticipants.add(entry.sipAddress)
									smartSearchBar.addAddressToIgnore(entry.sipAddress);
									++lastContacts.reloadCount
								},
							}]
						
						onEntryClicked: {
							selectedParticipants.append({$sipAddress:entry})
						}
						//resultExceptions: selectedParticipants
					}
					
					/*
				  TextField {
					id: filter
					
					Layout.fillWidth: true
					
					icon: 'search'
					
					onTextChanged: conferenceHelperModel.setFilter(text)
				  }
		  */
					Text{
						Layout.preferredHeight: 20
						Layout.rightMargin: 65
						Layout.alignment: Qt.AlignRight | Qt.AlignBottom
						Layout.topMargin: ConferenceManagerStyle.columns.selector.spacing
						text : 'Admin'
						
						color: Colors.g
						font.pointSize: Units.dp * 11
						font.weight: Font.Light
						visible: participantView.count > 0
						
					}
					ScrollableListViewField {
						Layout.fillHeight: true
						Layout.fillWidth: true
						Layout.bottomMargin: 5
						
						//readOnly: toAddView.count >= conferenceManager.maxParticipants
						textFieldStyle: TextFieldStyle.unbordered
						
						ParticipantsView {
							id: participantView
							anchors.fill: parent
							
							showContactAddress:false
							showSwitch : true
							showSeparator: false
							isSelectable: false
							
							
							actions: [{
									icon: 'remove_participant',
									tooltipText: 'Remove this participant from the selection',
									handler: function (entry) {
										smartSearchBar.removeAddressToIgnore(entry.sipAddress)
										selectedParticipants.remove(entry)
										++lastContacts.reloadCount
									}
								}]
							
							genSipAddress: ''
							
							model: ParticipantProxyModel {
								id:selectedParticipants
								chatRoomModel:null
								
							}
							
							onEntryClicked: actions[0].handler(entry)
							
						}
					}
					
				}
				
			}
			
			/*
				SearchBox{
					id: searchBox
					anchors.left:parent.left
					anchors.right:parent.right
					anchors.top:parent.top
					anchors.topMargin: 30
					anchors.leftMargin:15
					anchors.rightMargin: 15
					
					placeholderText:'Search contact or enter SIP address'
					
					entryHeight: 200
					SipAddressesView {
					  id: view
					  actions: [{
						icon: 'add',
							  secure:0,
								handler: function (entry) {
						  //searchBox.closeMenu()
						  //searchBox.launchVideoCall(entry.sipAddress)
						},
						visible: true
					  }]
					  genSipAddress: searchBox.filter
					  
					  model: SearchSipAddressesModel {}
					}
					
				}
				ScrollableListViewField {
					anchors.top:search.bottom
					anchors.bottom:parent.bottom
					anchors.left:parent.left
					anchors.right:parent.right
					anchors.leftMargin:15
					anchors.rightMargin: 15
					anchors.topMargin: 15
					
					
					SipAddressesView {
						id: toAddView
						
						anchors.fill: parent
						
						actions: [{
								icon: 'cancel',
								handler: function (entry) {
									//model.removeFromConference(entry.sipAddress)
								}
							}]
							
						//model: conferenceHelperModel.toAdd
						
						//onEntryClicked: actions[0].handler(entry)
					}
				}
			}*/
			Item{
				Layout.fillWidth: true
				Layout.preferredHeight: 20
				Text{
					anchors.fill:parent
					textFormat: Text.RichText
					text : '<span style="color:red">*</span> Obligatoire'
					//font.weight: Font.DemiBold
					color: Colors.g
					font.pointSize: Units.dp * 8
				}
			}
		}
	}
}