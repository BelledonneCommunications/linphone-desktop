import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import UtilsCpp 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Notification {
	id: notification
	
	icon: 'message_sign'
	
	// ---------------------------------------------------------------------------
	
	readonly property TimelineModel timelineModel: notificationData && notificationData.timelineModel 
	readonly property string peerAddress: notificationData && notificationData.peerAddress ||  ''
	readonly property string localAddress: notificationData && notificationData.localAddress || ''
	readonly property string fullPeerAddress: notificationData && notificationData.fullPeerAddress ||  ''
	readonly property string fullLocalAddress: notificationData && notificationData.fullLocalAddress || ''
	
	// ---------------------------------------------------------------------------
	
	Loader {
		active: timelineModel//Boolean(notification.peerAddress) && Boolean(notification.localAddress)
		anchors {
			fill: parent
			
			leftMargin: NotificationReceivedMessageStyle.leftMargin
			rightMargin: NotificationReceivedMessageStyle.rightMargin
			bottomMargin: NotificationReceivedMessageStyle.bottomMargin
		}
		
		sourceComponent: ColumnLayout {
			spacing: NotificationReceivedMessageStyle.spacing
			
			Contact {
				Layout.fillWidth: true
				property ChatRoomModel chatRoomModel : notification.timelineModel.getChatRoomModel()
				property var sipObserver: SipAddressesModel.getSipAddressObserver(notification.fullPeerAddress, notification.fullLocalAddress)
				subtitle: chatRoomModel.isOneToOne
							? SipAddressesModel.cleanSipAddress(notification.fullPeerAddress)
							: UtilsCpp.getDisplayName(notification.fullPeerAddress) 
				entry: chatRoomModel ? chatRoomModel : sipObserver
				Component.onDestruction: sipObserver=null// Need to set it to null because of not calling destructor if not.
			}
			
			Rectangle {
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				color: NotificationReceivedMessageStyle.messageContainer.colorModel.color
				radius: NotificationReceivedMessageStyle.messageContainer.radius
				
				Text {
					anchors {
						fill: parent
						margins: NotificationReceivedMessageStyle.messageContainer.margins
					}
					
					color: NotificationReceivedMessageStyle.messageContainer.text.colorModel.color
					elide: Text.ElideRight
					
					font {
						italic: true
						pointSize: NotificationReceivedMessageStyle.messageContainer.text.pointSize
					}
					
					verticalAlignment: Text.AlignVCenter
					text: notification.notificationData.message
					wrapMode: Text.Wrap
				}
			}
		}
	}
	
	MouseArea {
		anchors.fill: parent
		
		onClicked: notification._close(function () {
			AccountSettingsModel.setDefaultAccountFromSipAddress(notification.localAddress)
			notification.timelineModel.selected = true
			console.debug("Load conversation from notification")
			notification.notificationData.window.setView('Conversation', {
															 chatRoomModel:notification.timelineModel.getChatRoomModel()
														 })
			App.smartShowWindow(notification.notificationData.window)
		})
	}
}
