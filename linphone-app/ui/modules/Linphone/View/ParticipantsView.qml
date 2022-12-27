import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Common.Styles 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

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
	
	property string headerButtonDescription
	property string headerButtonIcon
	property var headerButtonAction
	property bool showHeader : true
	property bool showSubtitle : true
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
					color: SipAddressesViewStyle.entry.color.normal.color
					
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
												&& (!sipAddressesView.actions[index].visibleHandler || sipAddressesView.actions[index].visibleHandler({
																						   sipAddress: sipAddressesView.interpretableSipAddress
																					   }))
									
									onClicked: sipAddressesView.actions[index].handler({
																						   sipAddress: sipAddressesView.interpretableSipAddress
																					   })
									Icon{
										visible: modelData.secure>0 &&
											(sipAddressesView.actions[index].secureIconVisibleHandler ? sipAddressesView.actions[index].secureIconVisibleHandler({sipAddres:$modelData}) : true)
										icon: modelData.secure === 2?'secure_level_2':'secure_level_1'
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
						   ? SipAddressesViewStyle.header.color.pressed.color
						   : SipAddressesViewStyle.header.color.normal.color
					
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
							   ? SipAddressesViewStyle.header.text.color.pressed.color
							   : SipAddressesViewStyle.header.text.color.normal.color
						text: sipAddressesView.headerButtonDescription
					}
					
					Icon {
						anchors {
							right: parent.right
							rightMargin: SipAddressesViewStyle.header.rightMargin
							verticalCenter: parent.verticalCenter
						}
						
						icon: sipAddressesView.headerButtonIcon
						iconSize: parent.height
						
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
		
		color: SipAddressesViewStyle.entry.color.normal.color
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
					showSubtitle: sipAddressesView.showSubtitle
					function getStatus(){
						var count = 0;
						var txt = ''
						if( $modelData.adminStatus) {
					//: '(Admin)' : One word for Admin(istrator)
					//~ Context Little Header in one word for a column in participant
							txt += qsTr('participantsAdminHeader')
							++count
						}
						if( $modelData.isMe)
						//: 'Me' : One word for myself.
							txt += (count++ > 0 ? ' - ' : '') + qsTr('participantsMe')
						return txt
					}
					statusText : showAdminStatus ? getStatus()  : ''
					
					entry:  $modelData
					onAvatarClicked: sipAddressesView.entryClicked(parent.entry, index, contactView)
				}
				
				
				
				// ---------------------------------------------------------------------
				// Actions
				// ---------------------------------------------------------------------
				
				ActionBar {
					iconSize: SipAddressesViewStyle.entry.iconSize
					
					Switch{
						anchors.verticalCenter: parent.verticalCenter
						width:50
						indicatorStyle: SwitchStyle.aux
						
						visible: sipAddressesView.showSwitch
						
						enabled:true
						checked: $modelData.adminStatus
						onClicked: {
							$modelData.adminStatus = !checked
						}
					}
					
					Repeater {
						id: actionsRepeater
						model: sipAddressesView.actions
						
						Item{
							height: buttonAction.height
							width: buttonAction.width
							anchors.verticalCenter: parent.verticalCenter
							ActionButton {
								id: buttonAction
								isCustom: true
								backgroundRadius: 90
								colorSet: modelData.colorSet
								anchors.verticalCenter: parent.verticalCenter
								tooltipText: modelData.tooltipText? modelData.tooltipText:''
								visible: sipAddressesView.actions[index].visible && (!sipAddressesView.actions[index].visibleHandler || sipAddressesView.actions[index].visibleHandler(contactView.entry))
								
								onClicked: {
									sipAddressesView.actions[index].handler(contactView.entry)
								}
								Icon{
									visible: modelData.secure>0 &&
										(sipAddressesView.actions[index].secureIconVisibleHandler ? sipAddressesView.actions[index].secureIconVisibleHandler({sipAddres:$modelData}) : true)
									icon: modelData.secure === 2?'secure_level_2':'secure_level_1'
									iconSize: parent.height/2
									anchors.top:parent.top
									anchors.horizontalCenter: parent.right
								}
								Loader{
									anchors.verticalCenter: parent.verticalCenter
									anchors.horizontalCenter: parent.horizontalCenter
									height: parent.height - 2
									width: height
									
									active: index == actionsRepeater.count -1 && sipAddressesView.showInvitingIndicator && contactView.entry && contactView.entry.inviting
									
									sourceComponent: Component{
										BusyIndicator{
											color: BusyIndicatorStyle.alternateColor.color
											running: true
										}
									}
								}
							}
						}
					}
				}
			}
		}
		
		// Separator.
		Rectangle {
			color: SipAddressesViewStyle.entry.separator.colorModel.color
			height: SipAddressesViewStyle.entry.separator.height
			width: parent.width
			visible: sipAddressesView.showSeparator
		}
		
		// -------------------------------------------------------------------------
		
		states: State {
			when: mouseArea.containsMouse && sipAddressesView.isSelectable
			
			PropertyChanges {
				color: SipAddressesViewStyle.entry.color.hovered.color
				target: sipAddressEntry
			}
			
			PropertyChanges {
				color: SipAddressesViewStyle.entry.indicator.colorModel.color
				target: indicator
			}
		}
	}
}
