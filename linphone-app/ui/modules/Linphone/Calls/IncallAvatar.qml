import QtQuick 2.7

import Linphone 1.0

import UtilsCpp 1.0

import App.Styles 1.0

// =============================================================================

Avatar {
	id: mainItem
	property var call
	property var participantDeviceModel
	property ConferenceInfoModel conferenceInfoModel
	property bool isPreview: false
	property var _sipAddressObserver: participantDeviceModel
									  ? SipAddressesModel.getSipAddressObserver(participantDeviceModel.address, '')
									  : isPreview
										? SipAddressesModel.getSipAddressObserver( AccountSettingsModel.fullSipAddress, AccountSettingsModel.fullSipAddress)
										: call 
										  ? SipAddressesModel.getSipAddressObserver( call.fullPeerAddress, call.fullLocalAddress)
										  : null
	property var _username: conferenceInfoModel
							? conferenceInfoModel.subject
							: call && call.conferenceModel
							  ? call.conferenceModel.subject
							  : _sipAddressObserver
								? UtilsCpp.getDisplayName(_sipAddressObserver.peerAddress)
								: ''
	property bool isPaused: (call && (call.status === CallModel.CallStatusPaused)) || (participantDeviceModel && participantDeviceModel.isPaused) || false
	
	Component.onDestruction: _sipAddressObserver=null// Need to set it to null because of not calling destructor if not.
	
	backgroundColor: CallStyle.container.avatar.backgroundColor
	foregroundColor: mainItem.isPaused ? CallStyle.container.pause.color : 'transparent'
	
	image: {
		if (_sipAddressObserver) {
			var contact = _sipAddressObserver.contact
			return contact && contact.vcard.avatar
		}else
			return null;
	}
	
	username: (mainItem.isPaused || !_username) ? '' : _username
	Text {
		anchors.fill: parent
		color: CallStyle.container.pause.text.color
		
		// `|| 1` => `pointSize` must be greater than 0.
		font.pointSize: (width / CallStyle.container.pause.text.pointSizeFactor) || 1
		
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		
		text: '&#10073;&#10073;'
		textFormat: Text.RichText
		visible: mainItem.isPaused 
	}
}
