import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Rectangle {
	id: callControls
	
	// ---------------------------------------------------------------------------
	
	default property alias _content: content.data
	property alias isDarkMode: contact.isDarkMode
	
	property alias signIcon: signIcon.icon
	property alias subtitleColor: contact.subtitleColor
	property alias titleColor: contact.titleColor
	
	property string peerAddress
	property string localAddress
	property string fullPeerAddress
	property string fullLocalAddress
	
	property var entry
	
	// ---------------------------------------------------------------------------
	
	signal clicked
	
	// ---------------------------------------------------------------------------
	
	color: CallControlsStyle.colorModel.color
	height: CallControlsStyle.height
	
	MouseArea {
		anchors.fill: parent
		
		onClicked: callControls.clicked()
	}
	
	Icon {
		id: signIcon
		
		anchors {
			left: parent.left
			top: parent.top
		}
		
		iconSize: CallControlsStyle.signSize
	}
	
	RowLayout {
		anchors {
			fill: parent
			leftMargin: CallControlsStyle.leftMargin
			rightMargin: CallControlsStyle.rightMargin
		}
		
		spacing: 0
		
		Contact {
			id: contact
			
			Layout.fillHeight: true
			Layout.fillWidth: true
			
			displayUnreadMessageCount: true
			
			entry: callControls.entry
			onAvatarClicked: callControls.clicked()
		}
		
		Item {
			id: content
			
			Layout.fillHeight: true
			Layout.preferredWidth: callControls._content[0].width
		}
	}
}
