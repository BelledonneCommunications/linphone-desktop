import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Common.Styles 1.0

// =============================================================================

ScrollableListView {
	id: sipAddressesView
	
	// ---------------------------------------------------------------------------
	
	// Contains a list of: {
	//   icon: 'string',
	//   handler: function () { ... }
	// }
	property var actions: []
	
	property string genSipAddress
	
	// Optional parameters.chatRoomModel.isMeAdmin
	property string headerButtonDescription
	property string headerButtonIcon
	property var headerButtonAction
	property bool showHeader : true
	property bool showContactAddress : true
	property bool showSwitch : false
	property bool showSeparator : true
	property bool showAdminStatus : false
	property bool isSelectable : true
	property bool showInvitingIndicator : true
	property int hoveredCursor : Qt.PointingHandCursor
	
	property var switchHandler : function(checked, index){
	}
	
	
	readonly property string interpretableSipAddress: SipAddressesModel.interpretSipAddress(
														  genSipAddress, false
														  )
	
	// ---------------------------------------------------------------------------
	
	signal entryClicked (var entry, var index, var contactItem)
	
	
	// ---------------------------------------------------------------------------
	// Header.
	// ---------------------------------------------------------------------------
	
	header: MouseArea {
		height: {
			var height = headerButton.visible ? SipAddressesViewStyle.header.button.height : 0
			if (defaultContact.visible) {
				height += SipAddressesViewStyle.entry.height
			}
			return height
		}
		width: parent.width
		
		// Workaround to handle mouse.
		// Without it, the mouse can be given to items list when mouse is hover header.
		hoverEnabled: true
		cursorShape: Qt.ArrowCursor
		
		Column {
			anchors.fill: parent
			
			spacing: 0
			
			// -----------------------------------------------------------------------
			// Default contact.
			// -----------------------------------------------------------------------
			
			Loader {
				id: defaultContact
				
				height: SipAddressesViewStyle.entry.height
				width: parent.width
				
				visible: sipAddressesView.interpretableSipAddress.length > 0
				
				sourceComponent: Rectangle {
					anchors.fill: parent
					color: SipAddressesViewStyle.entry.color.normal
					
					RowLayout {
						anchors {
							fill: parent
							rightMargin: SipAddressesViewStyle.entry.rightMargin
						}
						spacing: 0
						
						Contact {
							id: contact
							
							Layout.fillHeight: true
							Layout.fillWidth: true
							
							entry: ({
										sipAddress: sipAddressesView.interpretableSipAddress,
										isOneToOne:true,
										haveEncryption:false,
										securityLevel:1
									})
						}
						
						ActionBar {
							id: defaultContactActionBar
							
							iconSize: SipAddressesViewStyle.entry.iconSize
							
							Repeater {
								model: sipAddressesView.actions
								
								ActionButton {
									isCustom: true
									backgroundRadius: 90
									colorSet: modelData.colorSet
									visible: sipAddressesView.actions[index].visible
									
									onClicked: sipAddressesView.actions[index].handler({
																						   sipAddress: sipAddressesView.interpretableSipAddress
																					   })
									Icon{
										visible: modelData.secure>0 &&
											(sipAddressesView.actions[index].secureIconVisibleHandler ? sipAddressesView.actions[index].secureIconVisibleHandler({sipAddres:$sipAddress}) : true)
										icon:modelData.secure === 2?'secure_level_2':'secure_level_1'
										iconSize:parent.height/2
										anchors.top:parent.top
										anchors.horizontalCenter: parent.right
									}
								}
							}
						}
					}
				}
			}
			
			// -----------------------------------------------------------------------
			// Header button.
			// -----------------------------------------------------------------------
			
			MouseArea {
				id: headerButton
				
				height: SipAddressesViewStyle.header.button.height
				width: parent.width
				
				visible: sipAddressesView.showHeader && !!sipAddressesView.headerButtonAction
				
				onClicked: sipAddressesView.headerButtonAction(sipAddressesView.interpretableSipAddress)
				
				Rectangle {
					anchors.fill: parent
					color: parent.pressed
						   ? SipAddressesViewStyle.header.color.pressed
						   : SipAddressesViewStyle.header.color.normal
					
					Text {
						anchors {
							left: parent.left
							leftMargin: SipAddressesViewStyle.header.leftMargin
							verticalCenter: parent.verticalCenter
						}
						
						font {
							bold: true
							pointSize: SipAddressesViewStyle.header.text.pointSize
						}
						
						color: headerButton.pressed
							   ? SipAddressesViewStyle.header.text.color.pressed
							   : SipAddressesViewStyle.header.text.color.normal
						text: sipAddressesView.headerButtonDescription
					}
					
					Icon {
						anchors {
							right: parent.right
							rightMargin: SipAddressesViewStyle.header.rightMargin
							verticalCenter: parent.verticalCenter
						}
						
						icon: sipAddressesView.headerButtonIcon
						iconSize: SipAddressesViewStyle.header.iconSize
						
						visible: icon.length > 0
					}
				}
			}
		}
	}
	
	// ---------------------------------------------------------------------------
	// Entries.
	// ---------------------------------------------------------------------------
	
	delegate: Rectangle {
		id: sipAddressEntry
		
		color: SipAddressesViewStyle.entry.color.normal
		height: SipAddressesViewStyle.entry.height
		width: parent ? parent.width : 0
		
		Rectangle {
			id: indicator
			
			anchors.left: parent.left
			color: 'transparent'
			height: parent.height
			width: SipAddressesViewStyle.entry.indicator.width
		}
		
		MouseArea {
			id: mouseArea
			
			anchors.fill: parent
			cursorShape: Qt.ArrowCursor
			
			RowLayout {
				anchors {
					fill: parent
					rightMargin: SipAddressesViewStyle.entry.rightMargin
				}
				spacing: 0
				
				// ---------------------------------------------------------------------
				// Contact or address info.
				// ---------------------------------------------------------------------
				
				Contact {
					id:contactView
					Layout.fillHeight: true
					Layout.fillWidth: true
					showContactAddress: sipAddressesView.showContactAddress
					//: '(Admin)' : One word for Admin(istrator)
					//~ Context Little Header in one word for a column in participant
					statusText : showAdminStatus && modelData.adminStatus ? qsTr('participantsAdminHeader') : ''
					
					entry:  modelData
					
					onAvatarClicked: sipAddressesView.entryClicked(parent.entry, index, contactView)
					
					BusyIndicator{
						anchors.verticalCenter: parent.verticalCenter
						anchors.horizontalCenter: parent.horizontalCenter
						width:15
						height:15
						running: sipAddressesView.showInvitingIndicator && modelData.inviting
					}
				}
				
				
				
				// ---------------------------------------------------------------------
				// Actions
				// ---------------------------------------------------------------------
				
				ActionBar {
					iconSize: SipAddressesViewStyle.entry.iconSize
					
					Switch{
						anchors.verticalCenter: parent.verticalCenter
						width:50
						//Layout.preferredWidth: 50
						indicatorStyle: SwitchStyle.aux
						
						visible: sipAddressesView.showSwitch
						
						enabled:true
						checked: modelData.adminStatus
						onClicked: {
							modelData.adminStatus = !checked
						}
					}
					
					Repeater {
						model: sipAddressesView.actions
						
						ActionButton {
							isCustom: true
							backgroundRadius: 90
							colorSet: modelData.colorSet
							anchors.verticalCenter: parent.verticalCenter
							tooltipText:modelData.tooltipText?modelData.tooltipText:''
							visible: sipAddressesView.actions[index].visible
							onClicked: {
								sipAddressesView.actions[index].handler(contactView.entry)
							}
							Icon{
								visible: modelData.secure>0 &&
									(sipAddressesView.actions[index].secureIconVisibleHandler ? sipAddressesView.actions[index].secureIconVisibleHandler({sipAddres:$sipAddress}) : true)
								icon:modelData.secure === 2?'secure_level_2':'secure_level_1'
								iconSize: parent.height/2
								anchors.top:parent.top
								anchors.horizontalCenter: parent.right
							}
						}
					}
				}
			}
		}
		
		// Separator.
		Rectangle {
			color: SipAddressesViewStyle.entry.separator.color
			height: SipAddressesViewStyle.entry.separator.height
			width: parent.width
			visible: sipAddressesView.showSeparator
		}
		
		// -------------------------------------------------------------------------
		
		states: State {
			when: mouseArea.containsMouse && sipAddressesView.isSelectable
			
			PropertyChanges {
				color: SipAddressesViewStyle.entry.color.hovered
				target: sipAddressEntry
			}
			
			PropertyChanges {
				color: SipAddressesViewStyle.entry.indicator.color
				target: indicator
			}
		}
	}
}
