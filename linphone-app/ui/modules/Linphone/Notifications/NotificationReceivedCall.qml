import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Notification {
	id: notification
	
	icon: 'call_sign_incoming'
	
	// ---------------------------------------------------------------------------
	
	readonly property var call: notificationData && notificationData.call
	
	// ---------------------------------------------------------------------------
	
	Loader {
		active: Boolean(notification.call)
		anchors {
			fill: parent
			
			leftMargin: NotificationReceivedCallStyle.leftMargin
			rightMargin: NotificationReceivedCallStyle.rightMargin
			bottomMargin: NotificationReceivedCallStyle.bottomMargin
		}
		
		sourceComponent: ColumnLayout {
			spacing: NotificationReceivedCallStyle.spacing     
			
			Contact {
				Layout.fillWidth: true
				/*
				property var peerAddress: notification.call ? notification.call.fullPeerAddress : ''
				onPeerAddressChanged: {
					entry=SipAddressesModel.getSipAddressObserver(peerAddress, notification.call ? notification.call.fullLocalAddress : '')
				}
				entry: SipAddressesModel.getSipAddressObserver(peerAddress, notification.call ? notification.call.fullLocalAddress : '')
				*/
				entry: notification.call
				Component.onDestruction: entry=null// Need to set it to null because of not calling destructor if not.
			}
			
			// ---------------------------------------------------------------------
			// Action buttons.
			// ---------------------------------------------------------------------
			
			Item {
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				ActionBar {
					id: acceptActionBar
					
					anchors.centerIn: parent
					iconSize: NotificationReceivedCallStyle.actionArea.iconSize
					
					ActionButton {
						isCustom: true
						backgroundRadius: 90
						colorSet: NotificationReceivedCallStyle.acceptVideoCall
						visible: SettingsModel.videoAvailable && notification.call.getRemoteVideoEnabled()
						
						onClicked: notification._close(notification.call.acceptWithVideo)
					}
					
					ActionButton {
						isCustom: true
						backgroundRadius: 90
						colorSet: NotificationReceivedCallStyle.acceptCall
						onClicked: notification._close(notification.call.accept)
					}
				}
				
				ActionBar {
					anchors {
						right: parent.right
						rightMargin: NotificationReceivedCallStyle.actionArea.rightButtonsGroupMargin
						verticalCenter: parent.verticalCenter
					}
					iconSize: NotificationReceivedCallStyle.actionArea.iconSize
					
					ActionButton {
						isCustom: true
						backgroundRadius: 90
						colorSet: NotificationReceivedCallStyle.hangup
						onClicked: notification._close(notification.call.terminate)
					}
				}
			}
		}
	}
}
