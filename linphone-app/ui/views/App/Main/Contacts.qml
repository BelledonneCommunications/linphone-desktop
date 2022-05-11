import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0

import App.Styles 1.0

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
		
		color: ContactsStyle.bar.backgroundColor
		
		RowLayout {
			anchors {
				fill: parent
				leftMargin: ContactsStyle.bar.leftMargin
				rightMargin: ContactsStyle.bar.rightMargin
			}
			spacing: ContactsStyle.spacing
			
			TextField {
				Layout.fillWidth: true
				icon: ContactsStyle.filter.icon
				overwriteColor: ContactsStyle.filter.color
				placeholderText: qsTr('searchContactPlaceholder')
				
				onTextChanged: contacts.setFilter(text)
			}
			
			ExclusiveButtons {
				texts: [
					qsTr('selectAllContacts'),
					qsTr('selectConnectedContacts')
				]
				
				onClicked: contacts.useConnectedFilter = !!button
			}
			
			TextButtonB {
				text: qsTr('addContact')
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
		color: ContactsStyle.backgroundColor
		
		ScrollableListView {
			anchors.fill: parent
			spacing: 0
			
			model: ContactsListProxyModel {
				id: contacts
			}
			
			delegate: Borders {
				bottomColor: ContactsStyle.contact.border.color
				bottomWidth: ContactsStyle.contact.border.width
				height: ContactsStyle.contact.height
				width: parent ? parent.width : 0
				
				// ---------------------------------------------------------------------
				
				Rectangle {
					id: contact
					
					anchors.fill: parent
					color: ContactsStyle.contact.backgroundColor.normal
					
					// -------------------------------------------------------------------
					
					Component {
						id: container1
						
						RowLayout {
							spacing: ContactsStyle.contact.spacing
							
							PresenceLevel {
								Layout.preferredHeight: ContactsStyle.contact.presenceLevelSize
								Layout.preferredWidth: ContactsStyle.contact.presenceLevelSize
								level: $modelData.presenceLevel
							}
							
							Text {
								Layout.fillWidth: true
								color: ContactsStyle.contact.presence.color
								elide: Text.ElideRight
								font.pointSize: ContactsStyle.contact.presence.pointSize
								text: Presence.getPresenceStatusAsString($modelData.presenceStatus)
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
									visible: SettingsModel.videoSupported && SettingsModel.outgoingCallsEnabled && SettingsModel.getShowStartVideoCallButton()
									
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
									visible: SettingsModel.secureChatEnabled
									enabled: AccountSettingsModel.conferenceURI != ''
									Icon{
										icon:'secure_level_1'
										iconSize:parent.height/2
										anchors.top:parent.top
										anchors.horizontalCenter: parent.right
									}
									onClicked: {actions.itemAt(3).open()}
									tooltipMaxWidth: actionBar.width
									tooltipVisible: AccountSettingsModel.conferenceURI == ''
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
												console.log("Load conversation from contacts")
												window.setView('Conversation', {
																   chatRoomModel: lastChatRoom
															   })
											}
						}
						
						readonly property var handlers: [
							CallsListModel.launchVideoCall,
							CallsListModel.launchAudioCall,
							function (sipAddress) {CallsListModel.launchChat( sipAddress,0 )},
							function (sipAddress) {CallsListModel.launchChat( sipAddress,1 )}
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
								
								color: ContactsStyle.contact.username.color
								elide: Text.ElideRight
								
								font {
									bold: true
									pointSize: ContactsStyle.contact.username.pointSize
								}
								
								text: $modelData.vcard.username
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
							color: ContactsStyle.contact.backgroundColor.hovered
							target: contact
						}
						
						PropertyChanges {
							color: ContactsStyle.contact.indicator.color
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
