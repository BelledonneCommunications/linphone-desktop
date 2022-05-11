import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import Linphone 1.0
import Linphone.Styles 1.0
import Common 1.0

import UtilsCpp 1.0

// =============================================================================

Rectangle {
	id: item
	
	// ---------------------------------------------------------------------------
	
	property alias sipAddressColor: description.sipAddressColor
	property alias usernameColor: description.usernameColor
	property alias statusText : description.statusText
	
	property bool displayUnreadMessageCount: false
	property bool showContactAddress : true
	property bool showAuxData : false
	
	// A entry from `SipAddressesModel` or an `SipAddressObserver`.
	property var entry
	
	// entry should have these functions : presenceStatus, sipAddress, username, avatar (image)
	
	property string username: (entry != undefined ?(entry.contactModel != undefined ? entry.contactModel.vcard.username
																			:entry.username != undefined ?entry.username:
																										   UtilsCpp.getDisplayName(entry.sipAddress || entry.fullPeerAddress  || entry.peerAddress || '')
											):'')
	signal avatarClicked(var mouse)
	// ---------------------------------------------------------------------------
	
	color: 'transparent' // No color by default.
	height: ContactStyle.height
	
	RowLayout {
		anchors {
			fill: parent
			leftMargin: ContactStyle.leftMargin
			rightMargin: ContactStyle.rightMargin
		}
		spacing: 0
		
		Avatar {
			id: avatar
			
			Layout.preferredHeight: ContactStyle.contentHeight
			Layout.preferredWidth: ContactStyle.contentHeight
			
			//image: _contact && _contact.vcard.avatar
			image: entry?(entry.contactModel	? entry.contactModel.vcard.avatar
												: entry.avatar ? entry.avatar : '')
						:''
			presenceLevel: entry?(entry.contactModel ? (entry.contactModel.presenceStatus >= 0 ? Presence.getPresenceLevel(entry.contactModel.presenceStatus) : -1)
													 : (entry.presenceStatus >= 0 ? Presence.getPresenceLevel(entry.presenceStatus) : -1)
								  )
								:-1
			
			//username: UtilsCpp.getDisplayName(entry.sipAddress || entry.peerAddress )
			
			username : entry!=undefined && entry.isOneToOne!=undefined && !entry.isOneToOne ? '' : item.username
						

			visible:!groupChat.visible
			Icon {
				
				anchors.fill: parent
				
				icon: ContactStyle.groupChat.icon
				overwriteColor: ContactStyle.groupChat.avatarColor
				iconSize: ContactStyle.contentHeight
				visible: entry!=undefined && entry.isOneToOne!=undefined && !entry.isOneToOne
			}
			
			Icon{
				anchors.top:parent.top
				anchors.horizontalCenter: parent.right
				visible: entry!=undefined && entry.haveEncryption != undefined && entry.haveEncryption
				icon: entry?(entry.securityLevel === 2?'secure_level_1': entry.securityLevel===3? 'secure_level_2' : 'secure_level_unsafe'):'secure_level_unsafe'
				iconSize: parent.height/2
			}
			MouseArea{
				anchors.fill: parent
				onClicked: item.avatarClicked(mouse)
			}
		}
		Icon {
			id: groupChat
			
			Layout.preferredHeight: ContactStyle.contentHeight
			Layout.preferredWidth: ContactStyle.contentHeight
			
			icon: ContactStyle.groupChat.icon
			overwriteColor: ContactStyle.groupChat.color
			iconSize: ContactStyle.contentHeight
			visible: false //entry!=undefined && entry.isOneToOne!=undefined && !entry.isOneToOne
			
			Icon{
				anchors.right: parent.right
				anchors.top:parent.top
				anchors.topMargin: -5
				visible: entry!=undefined && entry.haveEncryption != undefined && entry.haveEncryption
				icon: entry?(entry.securityLevel === 2?'secure_level_1': entry.securityLevel===3? 'secure_level_2' : 'secure_level_unsafe'):'secure_level_unsafe'
				iconSize:15
			}
		}
		
		ContactDescription {
			id: description
			
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.leftMargin: ContactStyle.spacing
			
			sipAddress: (entry && item.showContactAddress
						&& (item.showAuxData
							? entry.auxDataToShow || ''
							: (entry.isOneToOne == undefined || entry.isOneToOne) && (entry.haveEncryption == undefined || !entry.haveEncryption)
								? entry.sipAddress || entry.fullPeerAddress || entry.peerAddress || ''
								: '')
						) || ''
			participants: entry && item.showContactAddress && sipAddress == '' && entry.isOneToOne && entry.participants ? entry.participants.addressesToString : ''
			username: item.username
		}
		
		ContactMessageCounter {
			Layout.alignment: Qt.AlignTop
			
			count: entry?Number(entry.unreadMessagesCount) + Number(entry.missedCallsCount):0
			isComposing: Boolean(entry && entry.composers && entry.composers.length > 0)
			
			visible: entry?(entry.unreadMessagesCount !== null || entry.missedCallsCount !== null) && item.displayUnreadMessageCount:false
		}
	}
}
