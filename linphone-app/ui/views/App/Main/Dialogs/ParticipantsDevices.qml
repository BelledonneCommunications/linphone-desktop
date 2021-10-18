import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Utils 1.0
import UtilsCpp 1.0
import LinphoneUtils 1.0
import LinphoneEnums 1.0

import App.Styles 1.0
import Units 1.0
import ColorsList 1.0

import '../Conversation.js' as Logic

// =============================================================================

DialogPlus {
	id:dialog
	buttons: []
	flat : true
	
	title: "Conversation's devices"
	showCloseCross:true
	
	
	property ChatRoomModel chatRoomModel
	property var window
	buttonsAlignment: Qt.AlignCenter
	
	height: 383
	width: 450
	
	// ---------------------------------------------------------------------------
	
	ScrollableListViewField {
		anchors.fill:parent
		radius: 0
		
		ScrollableListView {
			id: view
			property var window : dialog.window
			anchors.fill: parent
			model: ParticipantProxyModel{
				chatRoomModel : dialog.chatRoomModel
			}
			
			delegate: 
				ColumnLayout{
				id:mainHeader
				property var window : ListView.view.window
				property int securityLevel : modelData.securityLevel
				property string addressToCall : modelData.sipAddress
						
				width: parent ? parent.width : undefined
				spacing: 0
				RowLayout {
					id: item
					Layout.fillWidth: true
					Layout.preferredHeight: 50
					Layout.minimumHeight: 50// Fix layout to avoid infinite update loop between ListView and RowLayout
					Layout.maximumHeight: 50
					Avatar{
						id:avatar
						Layout.preferredHeight: 32
						Layout.preferredWidth: 32
						Layout.leftMargin: 14
						username: modelData?(modelData.contactModel ? modelData.contactModel.vcard.username
																	:modelData.username?modelData.username:
																						 UtilsCpp.getDisplayName(modelData.sipAddress)
											 ):''
						Icon{
							property int securityLevel : modelData.securityLevel
							anchors.right: parent.right
							anchors.top:parent.top
							anchors.topMargin: -5
							visible: modelData && securityLevel !== 1
							icon: modelData?(securityLevel === 2?'secure_level_1': securityLevel===3? 'secure_level_2' : 'secure_level_unsafe'):'secure_level_unsafe'
							iconSize:15
							Timer{// Workaround : no security events are send when device's security change.
									onTriggered: parent.securityLevel = modelData.securityLevel
									repeat:true
									running:true
									interval:500
								}
						}
					}
					Item{
						Layout.fillHeight: true
						Layout.fillWidth: true
						Layout.leftMargin: 14
						ContactDescription{
							id:contactDescription
							anchors.fill:parent
							username: avatar.username
						}
						MouseArea{
									anchors.fill:contactDescription
									onClicked: {
										mainHeader.window.attachVirtualWindow(Qt.resolvedUrl('InfoEncryption.qml')
																   ,{securityLevel : mainHeader.securityLevel
																   , addressToCall : mainHeader.addressToCall}
																   )
									}
								}						
					}
					
					ActionButton {
						Layout.preferredHeight: 20
						Layout.preferredWidth: 20
						Layout.leftMargin: 14
						Layout.rightMargin: 14
						icon: modelData.deviceCount > 0?
								  (participantDevices.visible ? 'expanded' : 'collapsed')
								: (modelData.securityLevel === 2?'secure_level_1': 
																  (modelData.securityLevel===3? 'secure_level_2' : 'secure_level_unsafe')
								   )
						iconSize: 20
						visible:true
						useStates: false
						onClicked: participantDevices.visible = !participantDevices.visible
					}
				}
				Rectangle {
					color: ColorsList.add("ParticipantDevices_separator", "ag").color
					Layout.preferredHeight: 1
					Layout.fillWidth: true
				}
				ListView{
					id:participantDevices
					
					property var window : dialog.window
					
					visible: view.count < 4
					
					Layout.fillWidth: true
					Layout.preferredHeight: item.height * count
					
					interactive: false
					model: modelData.getProxyDevices()
					
					delegate: Rectangle{
						id:mainRectangle
						
						property var window : ListView.view.window
						property int securityLevel : modelData.securityLevel
						property string addressToCall : modelData.address
						
						width:parent.width
						height:50
						color: ColorsList.add("ParticipantDevices_line_background", "ah").color
						RowLayout{
							anchors.fill:parent
							Text{
								Layout.fillWidth: true
								Layout.fillHeight: true
								Layout.leftMargin: avatar.width+14*2
								font.weight: Font.Light
								font.pointSize: Units.dp * 11
								verticalAlignment: Text.AlignVCenter
								wrapMode: Text.WordWrap
								
								text:modelData.name
								
								MouseArea{
									anchors.fill:parent
									onClicked: {
										mainRectangle.window.attachVirtualWindow(Qt.resolvedUrl('InfoEncryption.qml')
																   ,{securityLevel : mainRectangle.securityLevel
																   , addressToCall : mainRectangle.addressToCall}
																   )
									}
								}
							}
							Icon{
								property int securityLevel : modelData.securityLevel
								Layout.rightMargin: 14
								Layout.preferredHeight: 20
								Layout.preferredWidth: 20
								visible: securityLevel !== 1
								icon: securityLevel === 2?'secure_level_1': securityLevel===3? 'secure_level_2' : 'secure_level_unsafe'
								iconSize:20
								Timer{// Workaround : no security events are send when device's security change.
									onTriggered: parent.securityLevel = modelData.securityLevel
									repeat:true
									running:true
									interval:500
								}
							}
						}
						Rectangle {
							color: ColorsList.add("ParticipantDevices_separator", "ag").color
							anchors.left : parent.left
							anchors.right  :parent.right
							anchors.bottom: parent.bottom
							height: 1
							visible: (index !== (model.count - 1))
						}
					}
				}
			}
		}
	}
}
