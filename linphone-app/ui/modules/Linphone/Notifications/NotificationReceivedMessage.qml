import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import UtilsCpp 1.0
import Units 1.0

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
							? UtilsCpp.toDisplayString(SipAddressesModel.cleanSipAddress(notification.fullPeerAddress), SettingsModel.sipDisplayMode)
							: UtilsCpp.getDisplayName(notification.fullPeerAddress) 
				entry: chatRoomModel ? chatRoomModel : sipObserver
				Component.onDestruction: sipObserver=null// Need to set it to null because of not calling destructor if not.
			}
			
			Rectangle {
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				color: NotificationReceivedMessageStyle.messageContainer.colorModel.color
				radius: NotificationReceivedMessageStyle.messageContainer.radius
				
				TextEdit {
					id: messageText
					property font customFont : SettingsModel.textMessageFont
					property string fullText: notification.notificationData.message
					anchors {
						fill: parent
						margins: NotificationReceivedMessageStyle.messageContainer.margins
					}
					
					color: NotificationReceivedMessageStyle.messageContainer.text.colorModel.color
					
					
					font {
						italic: true
						family: customFont.family
						pointSize: Units.dp * (customFont.pointSize - 1)
					}
					
					verticalAlignment: Text.AlignVCenter
					text: UtilsCpp.encodeTextToQmlRichFormat(metrics.elidedText)
					textFormat: Text.RichText
					wrapMode: Text.Wrap

					TextMetrics {
						id: metrics
						font: messageText.font
						text: messageText.fullText
						elideWidth: messageText.width
						elide: Qt.ElideRight
					}
				}
			}
		}
	}
	
	MouseArea {
		anchors.fill: parent
		
		onClicked: notification._close(function () {
			AccountSettingsModel.setDefaultAccountFromSipAddress(notification.localAddress)
			var chatroom = notification.timelineModel.getChatRoomModel()
			console.debug("Load conversation from notification: "+chatroom)
			//notification.notificationData.window.setView('Conversation', {
				//											 chatRoomModel: chatroom
					//									 })
			notification.timelineModel.selected = true
			App.smartShowWindow(notification.notificationData.window)
		})
	}
}
