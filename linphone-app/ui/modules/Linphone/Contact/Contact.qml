import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import Linphone 1.0
import LinphoneUtils 1.0
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
	
	// A entry from `SipAddressesModel` or an `SipAddressObserver`.
	property var entry
	
	// entry should have these functions : presenceStatus, sipAddress, username, avatar (image)
	
	//readonly property var _contact: entry.contact
	
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
			image: entry?(entry.contactModel?entry.contactModel.vcard.avatar:entry.avatar?entry.avatar: ''):''
			
			presenceLevel: entry?(entry.contactModel ? Presence.getPresenceLevel(entry.contactModel.presenceStatus)
													 : Presence.getPresenceLevel(entry.presenceStatus)
								  )
								:-1
			/*
	  Connections{
		  target: entry.contactModel?entry.contactModel:entry
		  onPresenceStatusChanged:{
			  if(entry){
				  if(entry.contactModel){
					  avatar.presenceLevel = Presence.getPresenceLevel(entry.contactModel.presenceStatus);
				  }else {
					  avatar.presenceLevel = Presence.getPresenceLevel(entry.presenceStatus);
				  }
			  }else {
				  avatar.presenceLevel =  -1;
			  }
		  }
	  }*/
			
			//username: LinphoneUtils.getContactUsername(_contact || entry.sipAddress || entry.fullPeerAddress  || entry.peerAddress || '')
			//username: UtilsCpp.getDisplayName(entry.sipAddress || entry.peerAddress )
			
			username : entry != undefined ?(entry.contactModel != undefined ? entry.contactModel.vcard.username
																		   :entry.username != undefined ?entry.username:
																										  LinphoneUtils.getContactUsername(entry.sipAddress || entry.fullPeerAddress  || entry.peerAddress || '')
										   ):''
						
			visible:!groupChat.visible
			Icon{
				anchors.right: parent.right
				anchors.top:parent.top
				anchors.topMargin: -5
				visible: entry!=undefined && entry.haveEncryption != undefined && entry.haveEncryption
				icon: entry?(entry.securityLevel === 2?'secure_level_1': entry.securityLevel===3? 'secure_level_2' : 'secure_level_unsafe'):'secure_level_unsafe'
				iconSize:15
			}
		}
		Icon {
			id: groupChat
			
			Layout.preferredHeight: ContactStyle.contentHeight
			Layout.preferredWidth: ContactStyle.contentHeight
			
			icon:'chat_room'
			iconSize: ContactStyle.contentHeight
			visible: entry!=undefined && entry.groupEnabled != undefined && entry.groupEnabled && entry.participants.count > 2
			
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
			
			//sipAddress: entry.sipAddress || entry.fullPeerAddress || entry.peerAddress || ''
			//sipAddress: (entry && showContactAddress? entry.sipAddress : '')
			
			sipAddress: (entry && showContactAddress
						 ? (entry.groupEnabled != undefined && entry.groupEnabled 
							? ''
							: (entry.haveEncryption != undefined && entry.haveEncryption
							   ? entry.participants.addressesToString()
							   : entry.sipAddress || entry.fullPeerAddress || entry.peerAddress || ''))
						 : '')
			/*
			  
	  sipAddress: (entry && showContactAddress?
					  (entry.contactModel != undefined  ?
						   entry.contactModel.vcard.address 
							: (entry.groupEnabled != undefined && entry.groupEnabled ? 'no group':
								(entry.haveEncryption != undefined && entry.haveEncryption?
									entry.participants.addressesToString()
									: entry.sipAddress || entry.fullPeerAddress || entry.peerAddress || '')
							   )
					   ):'No show')
		*/
			username: avatar.username
		}
		
		ContactMessageCounter {
			Layout.alignment: Qt.AlignTop
			
			count: entry?Number(entry.unreadMessagesCount) + Number(entry.missedCallsCount):0
			isComposing: Boolean(entry && entry.isComposing)
			
			visible: entry?(entry.unreadMessagesCount !== null || entry.missedCallsCount !== null) && item.displayUnreadMessageCount:false
		}
	}
}
