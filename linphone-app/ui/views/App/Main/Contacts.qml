import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import App.Styles 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils
// =============================================================================

ColumnLayout {
	function _removeContact (contact) {
		window.attachVirtualWindow(Utils.buildCommonDialogUri('ConfirmDialog'), {
									   descriptionText: qsTr('removeContactDescription'),
								   }, function (status) {
									   if (status) {
										   ContactsListModel.remove(contact)
									   }
								   })
	}
	
	spacing: 0
	
	// ---------------------------------------------------------------------------
	// Search Bar & actions.
	// ---------------------------------------------------------------------------
	
	Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: ContactsStyle.bar.height
		
		color: ContactsStyle.bar.backgroundColor.color
		
		RowLayout {
			anchors {
				fill: parent
				leftMargin: ContactsStyle.bar.leftMargin
				rightMargin: ContactsStyle.bar.rightMargin
			}
			spacing: ContactsStyle.spacing
			Text {
				Layout.preferredHeight: parent.height
				Layout.preferredWidth: contentWidth
				Layout.leftMargin: 10
				color: ContactsStyle.bar.foregroundColor.color
				font.pointSize: ContactsStyle.bar.pointSize
				font.weight: Font.Bold
				font.capitalization: Font.Capitalize
				text: LdapListModel.count > 0
				//: 'Local contacts' : Contacts section label in main window when we have to specify that they are local to the application.
											? qsTr('localContactsEntry')
				//: 'Contacts' : Contacts section label in main waindow.
											: qsTr('contactsEntry')
				verticalAlignment: Text.AlignVCenter
			}
			
			TextField {
				Layout.fillWidth: true
				icon: ContactsStyle.filter.icon
				iconSize: 35
				overwriteColor: ContactsStyle.filter.colorModel.color
				placeholderText: qsTr('searchContactPlaceholder')
				
				onTextChanged: contacts.setFilter(text)
			}
			
			ExclusiveButtons {
				texts: [
				//: 'All' : Filter label to display all items.
					qsTr('selectAllContacts'),
				//: 'Online' : Filter label to display only online contacts.
					qsTr('selectOnlineContacts')
				]
				capitalization: Font.AllUppercase
				onClicked: contacts.useOnlineFilter = !!button
			}
			Item{
				Layout.fillHeight: true
				Layout.fillWidth: true
			}
			TextButtonB {
				Layout.leftMargin: 20
				addHeight: 10
				addWidth: 80
				text: qsTr('addContact').toLowerCase()
				capitalization: Font.Capitalize
				onClicked: window.setView('ContactEdit')
			}
		}
	}
	
	// ---------------------------------------------------------------------------
	// Contacts list.
	// ---------------------------------------------------------------------------
	
	Rectangle {
		Layout.fillWidth: true
		Layout.fillHeight: true
		color: ContactsStyle.backgroundColor.color
		
		ScrollableListView {
			anchors.fill: parent
			spacing: 0
			
			model: ContactsListProxyModel {
				id: contacts
			}
			
			delegate: Borders {
				bottomColor: ContactsStyle.contact.border.colorModel.color
				bottomWidth: ContactsStyle.contact.border.width
				height: ContactsStyle.contact.height
				width: parent ? parent.width : 0
				
				// ---------------------------------------------------------------------
				
				Rectangle {
					id: contact
					
					anchors.fill: parent
					color: ContactsStyle.contact.backgroundColor.normal.color
					
					// -------------------------------------------------------------------
					
					Component {
						id: container1
						
						RowLayout {
							spacing: ContactsStyle.contact.spacing
							
							PresenceLevel {
								id: presenceLevel
								Layout.preferredHeight: ContactsStyle.contact.presenceLevelSize
								Layout.preferredWidth: ContactsStyle.contact.presenceLevelSize
								level: $modelData.presenceLevel
								timestamp: $modelData.presenceTimestamp
							}
							
							Text {
								Layout.fillWidth: true
								color: ContactsStyle.contact.presence.colorModel.color
								elide: Text.ElideRight
								font.pointSize: ContactsStyle.contact.presence.pointSize
								text: presenceLevel.text
								visible: presenceLevel.visible
							}
						}
					}
					
					Component {
						id: container2
						
						Item {
							ActionBar {
								id:actionBar
								anchors {
									left: parent.left
									verticalCenter: parent.verticalCenter
								}
								iconSize: ContactsStyle.contact.actionButtonsSize
								
								ActionButton {
									isCustom: true
									backgroundRadius: 90
									colorSet: ContactsStyle.videoCall
									visible: SettingsModel.videoAvailable && SettingsModel.outgoingCallsEnabled && SettingsModel.getShowStartVideoCallButton()
									
									onClicked: actions.itemAt(0).open()
								}
								
								ActionButton {
									isCustom: true
									backgroundRadius: 90
									colorSet: ContactsStyle.call
									visible: SettingsModel.outgoingCallsEnabled
									
									onClicked: actions.itemAt(1).open()
								}
								
								ActionButton {
									isCustom: true
									backgroundRadius: 90
									colorSet: SettingsModel.getShowStartChatButton() ? ContactsStyle.chat : ContactsStyle.history
									visible: SettingsModel.standardChatEnabled
									onClicked: actions.itemAt(2).open()
								}
								
								ActionButton {
									isCustom: true
									backgroundRadius: 90
									colorSet: SettingsModel.getShowStartChatButton() ? ContactsStyle.chat : ContactsStyle.history
									visible: SettingsModel.secureChatEnabled && $modelData && $modelData.hasCapability(LinphoneEnums.FriendCapabilityLimeX3Dh)
									enabled: AccountSettingsModel.conferenceUri != ''
									Icon{
										icon:'secure_level_1'
										iconSize:parent.height/2
										anchors.top:parent.top
										anchors.horizontalCenter: parent.right
									}
									onClicked: {actions.itemAt(3).open()}
									tooltipMaxWidth: actionBar.width
									tooltipVisible: AccountSettingsModel.conferenceUri == ''
										//: 'You need to set the conference URI in your account settings to create a conference based chat room.' : Tooltip to warn the user that a setting is missing in its configuration.
									tooltipText: '- ' + qsTr('missingConferenceURI') + '\n'
								}
							}
							
							ActionButton {
								isCustom: true
								backgroundRadius: 90
								colorSet: ContactsStyle.deleteAction
								anchors {
									right: parent.right
									verticalCenter: parent.verticalCenter
								}
								
								onClicked: _removeContact($modelData)
							}
						}
					}
					
					// -------------------------------------------------------------------
					
					Repeater {
						id: actions
						property ChatRoomModel lastChatRoom
						property ContactModel contactModel: $modelData
						
						Connections{
							target: lastChatRoom
							onStateChanged: if(state === 1) {
												console.debug("Load conversation from contacts")
												window.setView('Conversation')
											}
						}
						
						readonly property var handlers: [
							CallsListModel.launchVideoCall,
							CallsListModel.launchAudioCall,
							function (sipAddress) {
								var model = CallsListModel.launchChat( sipAddress,0 )
								if(model && model.chatRoomModel) {
									lastChatRoom = model.chatRoomModel
									window.setView('Conversations')
								}
							},
							function (sipAddress) {
								var model = CallsListModel.launchChat( sipAddress,1 )
								if(model && model.chatRoomModel) {
									lastChatRoom = model.chatRoomModel
									window.setView('Conversations')
								}}
						]
						
						model: handlers
						
						SipAddressesMenu {
							relativeTo: loader
							relativeY: loader.height
							sipAddresses: actions.contactModel.vcard.sipAddresses
							
							onSipAddressClicked: actions.handlers[index](sipAddress)
						}
					}
					
					// -------------------------------------------------------------------
					
					Rectangle {
						id: indicator
						
						anchors.left: parent.left
						color: 'transparent'
						height: parent.height
						width: ContactsStyle.contact.indicator.width
					}
					
					MouseArea {
						id: mouseArea
						
						anchors.fill: parent
						cursorShape: Qt.ArrowCursor
						
						MouseArea {
							anchors.fill: parent
							
							onClicked: window.setView('ContactEdit', {
														  sipAddress: $modelData.vcard.sipAddresses[0]
													  })
						}
						
						RowLayout {
							anchors {
								fill: parent
								leftMargin: ContactsStyle.contact.leftMargin
								rightMargin: ContactsStyle.contact.rightMargin
							}
							spacing: ContactsStyle.contact.spacing
							
							Item {
								Layout.preferredHeight: parent.height
								Layout.preferredWidth: parent.height
								
								Avatar {
									anchors.centerIn: parent
									
									image: $modelData.vcard.avatar
									username: $modelData.vcard.username
									
									height: ContactsStyle.contact.avatarSize
									width: ContactsStyle.contact.avatarSize
								}
							}
							
							Text {
								Layout.fillHeight: true
								Layout.preferredWidth: ContactsStyle.contact.username.width
								
								color: ContactsStyle.contact.username.colorModel.color
								elide: Text.ElideRight
								
								font {
									bold: true
									pointSize: ContactsStyle.contact.username.pointSize
								}
								font.family: SettingsModel.textMessageFont.family
								
								text: UtilsCpp.encodeTextToQmlRichFormat($modelData.vcard.username)
								textFormat: Text.RichText
								verticalAlignment: Text.AlignVCenter
							}
							
							// Container.
							Loader {
								id: loader
								
								Layout.fillWidth: true
								Layout.fillHeight: true
								sourceComponent: container1
							}
						}
					}
					
					// -------------------------------------------------------------------
					
					states: State {
						when: mouseArea.containsMouse
						
						PropertyChanges {
							color: ContactsStyle.contact.backgroundColor.hovered.color
							target: contact
						}
						
						PropertyChanges {
							color: ContactsStyle.contact.indicator.colorModel.color
							target: indicator
						}
						
						PropertyChanges {
							sourceComponent: container2
							target: loader
						}
					}
				}
			}
		}
	}
}
