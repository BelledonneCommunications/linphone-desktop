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
	// An entry from `SipAddressesModel`, an `SipAddressObserver` or a ChatRoomModel
	property var entry
	// entry should have these functions : presenceStatus, sipAddress, username, avatar (image)
	
	property alias subtitleColor: description.subtitleColor
	property alias titleColor: description.titleColor
	property alias statusText : description.statusText
	
	property bool displayUnreadMessageCount: false
	property bool showSubtitle : true
	property string subtitle: ''
	
	property string subject: (entry && entry.conferenceInfoModel && entry.conferenceInfoModel.subject
										? entry.conferenceInfoModel.subject
										: '')
	property string username: entry 
									? entry.username
										? entry.username
										: entry.contactModel
											? entry.contactModel.vcard.username
											: UtilsCpp.getDisplayName(entry.sipAddress || entry.fullPeerAddress  || entry.peerAddress || '')
									: ''
	property string organizer: entry && entry.conferenceInfoModel ? UtilsCpp.getDisplayName(entry.conferenceInfoModel.organizer) : ''
	
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
			image: entry?(entry.avatar ? entry.avatar
									: entry.contactModel ? entry.contactModel.vcard.avatar
														: '')
						:''
			presenceLevel: entry?(entry.contactModel ? (entry.contactModel.presenceStatus >= 0 ? Presence.getPresenceLevel(entry.contactModel.presenceStatus) : -1)
													 : (entry.presenceStatus >= 0 ? Presence.getPresenceLevel(entry.presenceStatus) : -1)
								  )
								:-1
			
			username: entry!=undefined 
						? entry.conferenceInfoModel
							? item.organizer
							: entry.isOneToOne!=undefined && !entry.isOneToOne
								? ''
								: item.username
						: item.username
			isOneToOne: entry==undefined || entry.isOneToOne==undefined || entry.isOneToOne
			
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
		
		ContactDescription {
			id: description
			
			Layout.fillHeight: true
			Layout.fillWidth: true
			Layout.leftMargin: ContactStyle.spacing
			
			titleText: item.subject
						? item.subject
						: item.username
			subtitleText: entry && item.showSubtitle
							? item.subtitle
								? item.subtitle
								: (entry.isOneToOne == undefined || entry.isOneToOne) && (entry.haveEncryption == undefined || !entry.haveEncryption)
									? item.organizer
										? item.organizer
										: entry.sipAddress || entry.fullPeerAddress || entry.peerAddress || ''
									: entry.participants.addressesToString
							: ''
		}
		
		ContactMessageCounter {
			Layout.alignment: Qt.AlignTop
			
			count: entry?Number(entry.unreadMessagesCount) + Number(entry.missedCallsCount):0
			isComposing: Boolean(entry && entry.composers && entry.composers.length > 0)
			
			visible: entry?(entry.unreadMessagesCount !== null || entry.missedCallsCount !== null) && item.displayUnreadMessageCount:false
		}
	}
}
